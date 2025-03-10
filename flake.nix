{
  outputs = { self, ... }: {
    dotnetTool = pkgs: pkgs.callPackage ./dotnet-tool.nix {};
    dotnetShell = pkgs: sdks: tools: pkgs.mkShell rec {
      dotnetPkg = pkgs.dotnetCorePackages.combinePackages (sdks pkgs.dotnetCorePackages);

      deps = with pkgs; [
        zlib
        zlib.dev
        openssl
        dotnetPkg
        (
          let 
            dt = (callPackage ./dotnet-tool.nix {});
          in
            dt.combineTools dotnetPkg (tools dt.tools)
        )
      ];

      NIX_LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath ([
        stdenv.cc.cc
      ] ++ deps);
      NIX_LD = "${pkgs.stdenv.cc.libc_bin}/bin/ld.so";
      packages = with pkgs; [ 
        omnisharp-roslyn
        netcoredbg
      ] ++ deps;

      DOTNET_ROOT = "${dotnetPkg}";

      shellHook = 
      ''
        PATH="~/.dotnet/tools:$PATH";
      '';
    };
  };
}
