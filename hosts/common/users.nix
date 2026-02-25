# User configuration
# Shared across all hosts
{
  config,
  pkgs,
  ...
}: {
  users.users.paradox = {
    isNormalUser = true;
    description = "Paradox";
    extraGroups = ["networkmanager" "wheel" "bluetooth"];
  };
}
