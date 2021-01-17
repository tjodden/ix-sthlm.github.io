with import <nixpkgs> {};

let
  my-theme = builtins.fetchTarball {
    url = "https://github.com/ix-sthlm/hyde-x/archive/master.tar.gz";
  };
  my-texlive = with pkgs; texlive.combine {
    inherit (texlive) scheme-basic
      # Needed on top of scheme-basic
      babel-english
      babel-swedish
      booktabs
      datetime2-english
      datetime2-swedish
      ec
      eurosym
      hyphen-english
      hyphen-swedish
      ulem

      # Needed on top of scheme-small
      cm-super

      # Needed on top of scheme-medium
      capt-of
      wrapfig

      # More deps for handling of indented paragrafs
      parskip
      etoolbox
    ;
  };

in stdenv.mkDerivation rec {
  name = "all";
  src = ./.;

  buildInputs = with pkgs; [
    gnumake
    hugo
    emacs26-nox
    nodePackages.svgo
    my-texlive
  ];

  patchPhase = ''
    patchShebangs .github/make_document_dirlist.sh
  '';

  buildPhase = ''
    make clean

    # Install theme
    mkdir -p themes
    cp -r ${my-theme} themes/hyde-x

    make color-logos
    make documents2pdf
    make dirlists
    make hugo
    make replace-favicon
    make cname
  '';

  installPhase = ''
    cp -vr public/ $out
  '';
}
