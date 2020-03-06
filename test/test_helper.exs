ExUnit.start()

{
  :error,
  {
    :EXIT,
    {
      :undef,
      [
        {ServiceGateway.SelectorWorkerMock, :start_link, [[]], []},
        {:supervisor, :do_start_child_i, 3, [file: 'supervisor.erl', line: 379]},
        {:supervisor, :handle_call, 3, [file: 'supervisor.erl', line: 404]},
        {:gen_server, :try_handle_call, 4, [file: 'gen_server.erl', line: 661]},
        {:gen_server, :handle_msg, 6, [file: 'gen_server.erl', line: 690]},
        {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 249]}
      ]
    }
  }
}