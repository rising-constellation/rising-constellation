defmodule RC.UploaderTest do
  use RC.DataCase
  use ExUnit.Case, async: false

  alias RC.Uploader
  alias RC.Uploader.Upload
  alias RC.Uploader.ImageUpload

  import RC.Fixtures

  @png_filename "test.png"
  @pdf_filename "test.pdf"
  @png_filepath Path.join([File.cwd!(), "test/support/", @png_filename])
  @pdf_filepath Path.join([File.cwd!(), "/test/support/", @pdf_filename])
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
  @original_name "test_original.png"
  @medium_name "test_medium.png"
  @thumb_name "test_thumb.png"
  @pdf_original_name "test_original.pdf"

  setup do
    on_exit(fn ->
      File.rm_rf(@stored_file_path)
      File.rm_rf(@stored_image_path)
    end)
  end

  defp get_path(user, filename) do
    Path.join([@stored_file_path, inspect(user.id), filename])
  end

  defp get_path_image(user, filename) do
    Path.join([@stored_image_path, inspect(user.id), filename])
  end

  describe "create" do
    setup [:create_account_user]

    test "creates a standard file", %{account: user} do
      assert {:ok, _e} =
               Uploader.create_standard_upload(%{
                 name: "test",
                 file: @pdf_filepath,
                 account_id: user.id,
                 content_type: "pdf"
               })

      path = get_path(user, @pdf_original_name)
      # Path.join([@stored_file_path, inspect(user.id), @pdf_original_name])

      assert File.exists?(path) == true
    end

    test "returns error if wrong format for standard file", %{account: user} do
      assert {:error, _e} =
               Uploader.create_standard_upload(%{
                 name: "test",
                 file: @png_filepath,
                 account_id: user.id,
                 content_type: "image"
               })

      path = get_path(user, @png_filename)

      assert File.exists?(path) == false
    end

    test "creates a image file", %{account: user} do
      assert {:ok, _e} =
               Uploader.create_image_upload(%{
                 name: "test",
                 file: @png_filepath,
                 account_id: user.id,
                 content_type: "image"
               })

      path_original = get_path_image(user, @original_name)
      path_medium = get_path_image(user, @medium_name)
      path_thumb = get_path_image(user, @thumb_name)

      assert File.exists?(path_original) == true
      assert File.exists?(path_medium) == true
      assert File.exists?(path_thumb) == true
    end

    test "returns error if wrong format for image file", %{account: user} do
      assert {:error, _e} =
               Uploader.create_image_upload(%{
                 name: "test",
                 file: @pdf_filepath,
                 account_id: user.id,
                 content_type: "invalid"
               })

      path_original = get_path_image(user, @original_name)
      path_medium = get_path_image(user, @medium_name)
      path_thumb = get_path_image(user, @thumb_name)

      assert File.exists?(path_original) == false
      assert File.exists?(path_medium) == false
      assert File.exists?(path_thumb) == false
    end
  end

  describe "list all uploads" do
    setup [:create_account_user]

    test "returns all uploads", %{account: user} do
      assert {:ok, _e} =
               Uploader.create_image_upload(%{
                 name: "test",
                 file: @png_filepath,
                 account_id: user.id,
                 content_type: "image"
               })

      assert {:ok, _e} =
               Uploader.create_standard_upload(%{
                 name: "test",
                 file: @pdf_filepath,
                 account_id: user.id,
                 content_type: "application"
               })

      assert {:ok, uploads} = Uploader.list_uploads()
      assert uploads.total_entries == 2
    end
  end

  describe "changeset" do
    setup [:create_account_user]

    test "of standard files returns error if image format", %{account: user} do
      changeset =
        Upload.changeset(
          %Upload{},
          %{
            name: "test",
            file: @png_filepath,
            account_id: user.id,
            content_type: "image"
          }
        )

      assert changeset.valid? == false
    end

    test "of image files returns error if not image format", %{account: user} do
      changeset =
        ImageUpload.changeset(
          %ImageUpload{},
          %{
            name: "test",
            file: @png_filepath,
            account_id: user.id,
            content_type: "invalid"
          }
        )

      assert changeset.valid? == false
    end

    test "of image files is valid if image format", %{account: user} do
      changeset =
        ImageUpload.changeset(
          %ImageUpload{},
          %{
            name: "test",
            file: @png_filepath,
            account_id: user.id,
            content_type: "image"
          }
        )

      assert changeset.valid? == true
    end
  end

  describe "delete" do
    setup [:create_account_user]

    test "deletes images upload", %{account: user} do
      {:ok, image_upload} =
        Uploader.create_image_upload(%{
          name: "test",
          file: @png_filepath,
          account_id: user.id,
          content_type: "image"
        })

      image_upload = Uploader.get_upload(image_upload.id)

      assert image_upload != nil

      assert {:ok, _chgset} = Uploader.delete_upload(image_upload)
    end

    test "deletes standard upload", %{account: user} do
      {:ok, std_upload} =
        Uploader.create_standard_upload(%{
          name: "test",
          file: @pdf_filepath,
          account_id: user.id,
          content_type: "pdf"
        })

      std_upload = Uploader.get_upload(std_upload.id)

      assert std_upload != nil

      assert {:ok, _chgset} = Uploader.delete_upload(std_upload)
    end
  end
end
