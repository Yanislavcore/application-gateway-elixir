ExUnit.start()
{:ok, _} = Application.ensure_all_started(:fake_server)
{:ok, _} = Application.ensure_all_started(:mojito)
