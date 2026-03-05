{ ... }:
{
  services.bitcoind.source = {
    enable = false;
    port = 38333;
    rpc.port = 38332;
    extraConfig = ''
      listen=1
      noconnect=1
      server=1
      bind=127.0.0.1
      whitelist=download@127.0.0.1
      addnode=148.251.128.115:33333
    '';
  };
}
