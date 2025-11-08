{ home-dir }: { ... }: 

{

  sops = {
    age.keyFile = "${home-dir}/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "accounts/google/user" = { };
      "accounts/google/pass" = { };
    };
  };
}
