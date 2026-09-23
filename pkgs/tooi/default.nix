{ lib, python3Packages, fetchPypi }:

let
  textual-fspicker = python3Packages.buildPythonPackage rec {
    pname = "textual-fspicker";
    version = "1.0.1";
    pyproject = true;

    src = fetchPypi {
      pname = "textual_fspicker";
      inherit version;
      hash = "sha256-WPf6mD3tel7Wm3J59m3leg72+tDjrLYi8hdoLoWYbJw=";
    };

    build-system = [ python3Packages.uv-build ];
    dependencies = [ python3Packages.textual ];
    pythonImportsCheck = [ "textual_fspicker" ];
  };
in
python3Packages.buildPythonApplication rec {
  pname = "tooi";
  version = "0.27.0";
  pyproject = true;

  src = fetchPypi {
    pname = "toot_tooi";
    inherit version;
    hash = "sha256-Hc0S44ZdXHn4aHOyHClNPchqg6isO7lvkp9VUyt74jw=";
  };

  build-system = with python3Packages; [ setuptools setuptools-scm ];

  dependencies = with python3Packages; [
    aiodns
    aiohttp
    beautifulsoup4
    certifi
    click
    html2text
    markdown-it-py
    linkify-it-py
    platformdirs
    pydantic
    rich
    textual
    textual-fspicker
    textual-image
    tomlkit
    typing-extensions
  ];

  pythonRelaxDeps = true;
  pythonImportsCheck = [ "tooi" ];

  meta = {
    description = "Mastodon terminal user interface";
    homepage = "https://codeberg.org/ihabunek/tooi";
    license = lib.licenses.mit;
    mainProgram = "tooi";
  };
}
