defmodule Godello.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @email_regex ~r/[\w-]+@([\w-]+\.)+[\w-]+/

  @derive {Jason.Encoder, only: [:id, :email, :first_name, :last_name]}
  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many(:boards, Godello.Kanban.Board, foreign_key: :owner_user_id)

    many_to_many(:users, Godello.Accounts.User,
      join_through: Godello.Kanban.BoardUser,
      on_replace: :delete,
      on_delete: :delete_all
    )

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :password])
    |> validate_required([:first_name, :last_name, :email, :password])
    |> validate_format(:email, @email_regex)
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password, required: true)
    |> put_password_hash()
    |> unique_constraint(:email)
  end

  def login_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, Pbkdf2.add_hash(password))
  end

  defp put_password_hash(changeset) do
    changeset
  end
end
