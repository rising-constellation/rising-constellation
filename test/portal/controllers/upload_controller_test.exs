defmodule Portal.UploadControllerTest do
  use Portal.APIConnCase

  alias RC.Uploader.Upload
  alias RC.Uploader.ImageUpload
  alias RC.Repo

  import RC.Fixtures

  @filename "test.png"
  @file_path Path.join([
               File.cwd!(),
               "/test/support/",
               @filename
             ])

  @pdf_filename "test.pdf"
  @pdf_file_path Path.join([File.cwd!(), "/test/support/", @pdf_filename])
  @stored_file_path Path.join([
                      File.cwd!(),
                      Application.compile_env(:waffle, :storage_dir),
                      Application.compile_env(:rc, RC.Uploader.StandardFile) |> Keyword.get(:path),
                      "accounts"
                    ])
  @stored_image_path Path.join([
                       File.cwd!(),
                       Application.compile_env(:waffle, :storage_dir),
                       Application.compile_env(:rc, RC.Uploader.ImageFile) |> Keyword.get(:path),
                       "accounts"
                     ])

  @image_plug_upload %Plug.Upload{
    content_type: "image/png",
    filename: @filename,
    path: @file_path
  }

  @pdf_plug_upload %Plug.Upload{
    content_type: "application/pdf",
    filename: @pdf_filename,
    path: @pdf_file_path
  }

  def fixture_standard_upload(account) do
    {:ok, upload} =
      %Upload{}
      |> Upload.changeset(%{
        name: @pdf_filename,
        file: @pdf_file_path,
        account_id: account.id,
        content_type: "test"
      })
      |> Repo.insert()

    upload
  end

  defp get_path(user, filename) do
    Path.join([@stored_file_path, inspect(user.id), filename])
  end

  defp get_path_image(user, filename) do
    Path.join([@stored_image_path, inspect(user.id), filename])
  end

  def fixture_image_upload(account) do
    {:ok, upload} =
      %ImageUpload{}
      |> ImageUpload.changeset(%{name: @filename, file: @file_path, account_id: account.id, content_type: "image"})
      |> Repo.insert()

    upload
  end

  setup %{conn: conn} do
    on_exit(fn ->
      File.rm_rf(@stored_file_path)
      File.rm_rf(@stored_image_path)
    end)

    Portal.Config.update_key(:signup_mode, Application.get_env(:rc, :signup_mode))
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index uploads" do
    setup [:create_account_admin]

    test "returns empty list if empty", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> get(Routes.upload_path(conn, :index))

      assert json_response(conn, 200) == []
      assert conn.assigns.uploads.total_entries == 0
    end

    test "returns one upload if only one upload", %{conn: conn, account: account} do
      upload = fixture_standard_upload(account)

      conn =
        conn
        |> login(account)
        |> get(Routes.upload_path(conn, :index))

      [upload_controller] = json_response(conn, 200)

      assert upload_controller["id"] == upload.id
      assert upload_controller["file"]["file_name"] == upload.file.file_name
      assert upload_controller["account_id"] == upload.account_id
      assert upload_controller["account_name"] == account.name
      assert upload_controller["account_role"] == Atom.to_string(account.role)
      assert conn.assigns.uploads.total_entries == 1
    end

    test "returns uploads", %{conn: conn, account: account} do
      fixture_standard_upload(account)
      fixture_image_upload(account)

      conn =
        conn
        |> login(account)
        |> get(Routes.upload_path(conn, :index))

      assert conn.assigns.uploads.total_entries == 2
    end

    test "returns image uploads if image filter", %{conn: conn, account: account} do
      _upload = fixture_standard_upload(account)
      img_upload = fixture_image_upload(account)

      conn =
        conn
        |> login(account)
        |> get(Routes.upload_path(conn, :index), %{content_type: "image"})

      [upload_controller] = json_response(conn, 200)

      assert upload_controller["id"] == img_upload.id
      assert upload_controller["file"]["file_name"] == img_upload.file.file_name
      assert upload_controller["account_id"] == img_upload.account_id
      assert upload_controller["account_name"] == account.name
      assert upload_controller["account_role"] == Atom.to_string(account.role)
      assert conn.assigns.uploads.total_entries == 1
    end

    test "returns filtered uploads", %{conn: conn, account: account} do
      _upload = fixture_standard_upload(account)

      conn =
        conn
        |> login(account)
        |> get(Routes.upload_path(conn, :index), %{content_type: "non_existing_content_type"})

      assert [] = json_response(conn, 200)
      assert conn.assigns.uploads.total_entries == 0
    end
  end

  describe "create upload" do
    setup [:create_account_admin]

    test "uploads a standard file", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.upload_path(conn, :upload), %{name: "some name", file: @pdf_plug_upload})

      assert json_response(conn, 201)["message"] == "standard_file_uploaded"
      assert File.exists?(get_path(account, "test_original.pdf")) == true
    end

    test "uploads a image file", %{conn: conn, account: account} do
      conn =
        conn
        |> login(account)
        |> post(Routes.upload_path(conn, :upload), %{name: "some name", file: @image_plug_upload})

      assert json_response(conn, 201)["message"] == "image_file_uploaded"
      assert File.exists?(get_path_image(account, "test_original.png")) == true
      assert File.exists?(get_path_image(account, "test_medium.png")) == true
      assert File.exists?(get_path_image(account, "test_thumb.png")) == true
    end
  end

  describe "delete" do
    setup [:create_account_admin]

    test "deletes standard upload", %{conn: conn, account: account} do
      upload = fixture_standard_upload(account)

      conn =
        conn
        |> login(account)
        |> delete(Routes.upload_path(conn, :delete, upload.id))

      assert response(conn, 204)
    end

    test "deletes image upload", %{conn: conn, account: account} do
      upload = fixture_image_upload(account)

      conn =
        conn
        |> login(account)
        |> delete(Routes.upload_path(conn, :delete, upload.id))

      assert response(conn, 204)
    end

    test "returns error if wrong upid", %{conn: conn, account: account} do
      upload = fixture_image_upload(account)

      conn =
        conn
        |> login(account)
        |> delete(Routes.upload_path(conn, :delete, upload.id * 2))

      assert json_response(conn, 404)["message"] == "upload_not_found"
    end
  end
end
