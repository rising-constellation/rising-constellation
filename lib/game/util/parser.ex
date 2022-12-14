# Derived from: https://github.com/adobe/bot_army/blob/68369a846d13e4ff973fdbc5decd418cc6e80f43/LICENSE
# MIT License © Copyright 2020 Adobe. All rights reserved.

defmodule Instance.SystemAI.Parser do
  @moduledoc """
  Parses JSON files created from the [Behavior Tree visual
  editor](https://github.com/adobe/behavior_tree_editor) into a `BehaviorTree.Node`,
  ready to be supplied to a bot.

  Note, you can automatically import your defined Actions into the visual editor with
  the included `mix bots.extract_actions` mix task:

  `mix bots.extract_actions --actions-dir lib/actions/ --module-base MyProject.Actions --bt-json-file lib/trees/tree.json`
  """

  alias BehaviorTree.Node
  import SystemAI.Actions, only: [action: 3]

  @doc """
  Parses the requested tree in the supplied JSON file created with the visual editor.

  The `tree` parameter should match the title of the tree in the editor.

  The following `opts` are allowed:

  * `context` - a map of keys and values to be merged onto the root node's properties
  (overwriting any existing keys).
  * `module_base` -  a common module base to prefix each parsed generic function
  style action and custom action.  Useful in combination with the `module-base` flag
  on the `bots.extract_actions` mix task.
  """
  @spec parse!(path :: String.t(), tree :: String.t(), opts :: Keyword.t()) ::
          BehaviorTree.Node.t()
  def parse!(path, tree_title, opts \\ []) do
    project =
      path
      |> File.read!()
      |> Jason.decode!()
      |> (fn
            # json output via save to file has a "wrapping" layer, whereas copy/paste
            # from Project > Export does not
            %{"data" => data} ->
              data

            full ->
              full
          end).()

    root_tree =
      project["trees"]
      |> Enum.find(fn
        %{"title" => ^tree_title} -> true
        _ -> false
      end)

    unless root_tree,
      do:
        raise(
          "Unable to find tree \"#{inspect(tree_title)}\"  Found trees: #{project["trees"] |> Enum.map(& &1["title"]) |> Enum.join(", ")}"
        )

    context = Keyword.get(opts, :context, %{})
    context_with_string_keys = for {k, v} <- context, into: %{}, do: {to_string(k), v}

    project_with_module_base = Map.put(project, "module_base", Keyword.get(opts, :module_base))

    tree =
      root_tree
      |> Map.update!("properties", &Map.merge(&1, context_with_string_keys))
      |> convert_tree(project_with_module_base)

    tree
  end

  defp get_tree(id, project) do
    Enum.find(
      project["trees"],
      fn
        %{"id" => ^id} -> true
        _ -> false
      end
    )
  end

  defp get_node(id, tree) do
    Map.get(tree["nodes"], id)
  end

  # Given context of `%{num: 1, "str" -> "hi"}`
  # `replace_templates!("9, {{{num}}, {{str}}", context)` -> `~s(9, 1, "hi")`
  # `replace_templates!("{{num}}", context)` -> `~s(9)`
  # `replace_templates!("{{str}}", context)` -> `~s("hi")`
  defp replace_templates!(str, context) when is_binary(str) and is_map(context) do
    Regex.replace(~r/{{([^}]+)}}/, str, fn _whole_match, key ->
      value = Map.get(context, key)

      unless value,
        do:
          raise(
            ~s(Unable to find a property with key `#{key}`in this node's tree's properties. Defined properties: `#{inspect(context)}`)
          )

      # The looked-up value might be an int, which doesn't work with Regex.replace
      # (becomes a binary), so we must to_string it first
      # Otherwise, it needs to be wrapped in quotes to appear as it would if it were
      # specified directly, (see examples above function)
      case value do
        i when is_integer(i) -> to_string(i)
        other -> ~s("#{other}")
      end
    end)
  end

  defp ensure_int(int) when is_integer(int), do: {:ok, int}

  defp ensure_int(other) do
    case Integer.parse(other) do
      {n, ""} -> {:ok, n}
      _ -> {:error, other}
    end
  end

  defp get_properties(node, context) do
    node["properties"]
    |> Enum.map(fn {k, v} ->
      {k,
       v
       # properties might be ints, so ensure they are strings for replace_templates!
       # and BT.TermParser.parse to work
       |> to_string
       |> replace_templates!(context)
       |> Instance.SystemAI.TermParser.parse()
       |> case do
         {:ok, parsed} ->
           parsed

         e ->
           raise(
             ~s(Cannot parse property "#{k}" with value `#{v}` in #{inspect(node["properties"])}, error #{inspect(e)})
           )
       end}
    end)
    |> Enum.into(%{})
  end

  defp extract_args!(str, context) when is_binary(str) do
    [_all, args] = Regex.run(~r/^[^(]+\(([^)]*)\)/, str)
    args |> parse_args!(context)
  end

  defp parse_args!(args, context) do
    case args |> replace_templates!(context) |> (&("[" <> &1 <> "]")).() |> Instance.SystemAI.TermParser.parse() do
      {:ok, parsed_args} ->
        parsed_args

      {:error, e} ->
        raise ~s(Unable to parse args `#{args}`.  Make sure they are in a valid Elixir terms format, like `"my_string", 99, false, [opt_a: true], %{name: "Tom"}`.
          Raw error: #{inspect(e, pretty: true)})
    end
  end

  defp print_mfa(m, f, a) do
    String.trim_leading(to_string(m), "Elixir.") <>
      "." <> to_string(f) <> "/" <> to_string(Enum.count(a) + 1)
  end

  defp parse_action_syntax(str, module_base, context) when is_binary(str) do
    case String.starts_with?(str, ":") do
      true -> parse_atom_action(str, module_base, context)
      false -> parse_function_action(str, module_base, context)
    end
  end

  defp parse_atom_action(str, _module_base, _context) when is_binary(str) do
    with {:format?, [_all, atom_name]} <-
           {:format?, Regex.run(~r/^:(.*)/, str)},
         atom <- String.to_atom(atom_name) do
      {:ok, atom}
    else
      {:format?, _} ->
        raise "Unable to parse atom \"#{str}\"."

      {:exists?, name, false} ->
        raise "The provided action does not exist: \"#{name}\""

      e ->
        {:error, e}
    end
  end

  defp parse_function_action(str, module_base, context) when is_binary(str) do
    with {:format?, [_all, mod_fn, args_str]} <-
           {:format?, Regex.run(~r/^([^(]+)\((.*)\)(?:\s.+|$)/, str)},
         {:format?, [function_str | mod_reversed]} when mod_reversed != [] and function_str != "" <-
           {:format?, mod_fn |> String.split(".") |> Enum.reverse()},
         args <- args_str |> parse_args!(context),
         mod <-
           mod_reversed
           |> Enum.reverse()
           |> List.insert_at(0, module_base)
           |> Module.concat(),
         function <- String.to_atom(function_str),
         # If the action module is never used (which is likely the case when
         # parsing from json) it won't get loaded
         Code.ensure_loaded(mod),
         {:exists?, _, true} <-
           {:exists?, print_mfa(mod, function, args),
            function_exported?(
              mod,
              function,
              # add 1 for the implicit "context" argument that gets tacked on
              Enum.count(args) + 1
            )} do
      {:ok, {mod, function, args}}
    else
      {:format?, _} ->
        raise "Runner/custom action nodes must have a title like \"Module.Submodule.function_name(1,2,3)\" all in valid Elixir terms.  Unable to parse \"#{str}\"."

      {:exists?, name, false} ->
        raise "The provided action does not exist: \"#{name}\""

      e ->
        {:error, e}
    end
  end

  ###### Conversions

  ### Tree

  defp convert_tree(tree, project) do
    tree["root"]
    |> get_node(tree)
    |> convert_node(tree, project)
  end

  ### Composites

  defp convert_node(%{"name" => "sequence"} = node, tree, project) do
    children =
      node["children"]
      |> Enum.map(fn node_id ->
        node_id
        |> get_node(tree)
        |> convert_node(tree, project)
      end)

    Node.sequence(children)
  end

  defp convert_node(%{"name" => "select"} = node, tree, project) do
    children =
      node["children"]
      |> Enum.map(fn node_id ->
        node_id
        |> get_node(tree)
        |> convert_node(tree, project)
      end)

    Node.select(children)
  end

  defp convert_node(%{"name" => "random"} = node, tree, project) do
    children =
      node["children"]
      |> Enum.map(fn node_id ->
        node_id
        |> get_node(tree)
        |> convert_node(tree, project)
      end)

    Node.random(children)
  end

  defp convert_node(%{"name" => "random_weighted"} = node, tree, project) do
    children =
      node["children"]
      |> Enum.map(fn node_id ->
        child = get_node(node_id, tree)

        with %{"weight" => weight_val} <- get_properties(child, tree["properties"]),
             {:ok, weight} when weight_val > 0 <- ensure_int(weight_val) do
          {convert_node(child, tree, project), weight}
        else
          e ->
            raise "All children nodes of a Random weighted node must have a \"weight\" proprty as an integer greater than 0, got: #{inspect(child, pretty: true)}
            specific error: #{inspect(e, pretty: true)}"
        end
      end)

    Node.random_weighted(children)
  end

  ### Decorators

  defp convert_node(%{"name" => "repeat_until_succeed"} = node, tree, project) do
    child =
      node["child"]
      |> get_node(tree)
      |> convert_node(tree, project)

    Node.repeat_until_succeed(child)
  end

  defp convert_node(%{"name" => "repeat_until_fail"} = node, tree, project) do
    child =
      node["child"]
      |> get_node(tree)
      |> convert_node(tree, project)

    Node.repeat_until_fail(child)
  end

  defp convert_node(%{"name" => "negate"} = node, tree, project) do
    child =
      node["child"]
      |> get_node(tree)
      |> convert_node(tree, project)

    Node.negate(child)
  end

  defp convert_node(%{"name" => "always_fail"} = node, tree, project) do
    child =
      node["child"]
      |> get_node(tree)
      |> convert_node(tree, project)

    Node.always_fail(child)
  end

  defp convert_node(%{"name" => "always_succeed"} = node, tree, project) do
    child =
      node["child"]
      |> get_node(tree)
      |> convert_node(tree, project)

    Node.always_succeed(child)
  end

  defp convert_node(%{"name" => "repeat_n"} = node, tree, project) do
    child =
      node["child"]
      |> get_node(tree)
      |> convert_node(tree, project)

    with %{"n" => n_val} <- get_properties(node, tree["properties"]),
         {:ok, n} when n > 1 <- ensure_int(n_val) do
      Node.repeat_n(n, child)
    else
      e ->
        raise "Repeater nodes must have a `n` integer property greater than 1, got: #{inspect(node["properties"], pretty: true)}
        , specific error: #{inspect(e, pretty: true)}"
    end
  end

  ### Actions

  defp convert_node(%{"name" => "runner"} = node, tree, project) do
    case parse_action_syntax(node["title"], project["module_base"], tree["properties"]) do
      {:ok, {mod, function, args}} ->
        action(mod, function, args)

      {:ok, atom} when is_atom(atom) ->
        atom

      {:error, e} ->
        raise "Unknown error parsing \"#{node["title"]}\", error: #{inspect(e, pretty: true)}"
    end
  end

  defp convert_node(%{"name" => "error"} = node, tree, _project) do
    args = extract_args!(node["title"], tree["properties"])

    action(BT.Actions, :error, args)
  end

  defp convert_node(%{"name" => "wait"} = node, tree, _project) do
    args = extract_args!(node["title"], tree["properties"])

    unless match?([n | _] when n > 0, args),
      do:
        raise(
          "Wait nodes must have a \"seconds\" property greater than or equal to 0, or two integers like `wait(1, 10)`; got #{inspect(args)}"
        )

    action(BT.Actions, :wait, args)
  end

  defp convert_node(%{"name" => "log"} = node, tree, _project) do
    args = extract_args!(node["title"], tree["properties"])
    action(BT.Actions, :log, args)
  end

  defp convert_node(%{"name" => "succeed_rate"} = node, tree, _project) do
    args = extract_args!(node["title"], tree["properties"])

    unless match?([i] when i > 0 and i < 1, args),
      do:
        raise(
          "Succeed Rate nodes must have a \"rate\" argument between 0 and 1 like `succeed_rate(0.75); got #{inspect(args)}"
        )

    action(BT.Actions, :succeed_rate, args)
  end

  defp convert_node(%{"name" => "done"}, _tree, _project) do
    action(BT.Actions, :done, [])
  end

  defp convert_node(node, tree, project) do
    # might be a tree, check if the name is one of the tree ids, or might be a custom
    # action node, check if the format is correct
    #
    case get_tree(node["name"], project) do
      target_tree when not is_nil(target_tree) ->
        node_props = get_properties(node, tree["properties"])

        target_tree
        |> Map.update!("properties", &Map.merge(&1, node_props))
        |> convert_tree(project)

      nil ->
        case parse_action_syntax(node["title"], project["module_base"], tree["properties"]) do
          {:ok, {mod, function, args}} ->
            action(mod, function, args)

          {:ok, atom} when is_atom(atom) ->
            atom

          {:error, _} ->
            raise "Unknown node type: \"#{inspect(node, pretty: true)}\""
        end
    end
  end
end
