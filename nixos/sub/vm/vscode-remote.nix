# VSCode Remote SSH workaround for VM
{ config, pkgs, ... }:
{
  # thanks to this video https://www.youtube.com/watch?v=CbDVUjbqIhc
  systemd.user = {
    paths.vscode-remote-workaround = {
      wantedBy = ["default.target"];
      pathConfig.PathChanged = "%h/.vscode-server/bin";
    };
    services.vscode-remote-workaround.script = ''
      for i in ~/.vscode-server/bin/*; do
        echo "Fixing vscode-server in $i..."
        ln -sf ${pkgs.nodejs_22}/bin/node $i/node
      done
    '';
  };
}

