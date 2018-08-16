defmodule FireAuth.SecureTest do
  use ExUnit.Case
  use Plug.Test

  defmodule NoGroupRouter do
    use Plug.Router

    plug FireAuth.Secure

    match _, do: send_resp(conn, 200, "")
  end

  defmodule GroupRouter do
    use Plug.Router

    plug FireAuth.Secure, group: "admin"

    match _, do: send_resp(conn, 200, "")
  end


  test "secured route halts without logged in user" do
    conn = conn(:get, "/some_route")
            |> NoGroupRouter.call(NoGroupRouter.init([]))

    assert conn.halted
  end

  test "secured route continues with logged in user" do
    conn = conn(:get, "/some_route")
            |> assign(:fire_auth, %{authenticated: true})
            |> NoGroupRouter.call(NoGroupRouter.init([]))

    refute conn.halted
  end

  test "route secured with group refuses user without this group" do
    conn = conn(:get, "/some_route")
            |> assign(:fire_auth, %{authenticated: true, groups: ["moderator"]})
            |> GroupRouter.call(GroupRouter.init([]))

    assert conn.halted
  end

  test "route secured with group allows user with this group" do
    conn = conn(:get, "/some_route")
            |> assign(:fire_auth, %{authenticated: true, groups: ["moderator", "admin"]})
            |> GroupRouter.call(GroupRouter.init([]))

    refute conn.halted
  end

  def load_user(_) do
    %{}
  end
  def load_groups(_, _) do
    []
  end
end
