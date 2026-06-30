{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      python3 = prev.python3.override {
        packageOverrides = pyfinal: pyprev: {
          "honcho-ai" = pyprev.buildPythonPackage rec {
            pname = "honcho-ai";
            version = "2.1.2";
            pyproject = true;

            src = pkgs.fetchurl {
              url = "https://files.pythonhosted.org/packages/eb/15/31d391c007047cd40cd05943312d807b16f7b977c168fce1f3efdc8dff27/honcho_ai-${version}.tar.gz";
              hash = "sha256-8sAUY5MeGhbMQ5Z5DhsDh9WW+1641tyDDWq3QvhwEiQ=";
            };

            nativeBuildInputs = with pyprev; [ setuptools wheel ];
            propagatedBuildInputs = with pyprev; [ httpx pydantic typing-extensions ];

            doCheck = false;

            meta = with lib; {
              description = "Official DX Optimized Python SDK for Honcho";
              homepage = "https://github.com/plastic-labs/honcho";
              license = licenses.asl20;
            };
          };
        };
      };
    })
  ];

  environment.systemPackages = [
    (pkgs.python3.withPackages (ps: [ ps."honcho-ai" ]))
  ];
  environment.variables.PYTHONPATH = "${pkgs.python3.withPackages (ps: [ ps. "honcho-ai" ])}/${pkgs.python3.sitePackages}";
}
