#!perl
use strict;
use warnings;

use lib 't';
use helper;
use Cwd qw(abs_path);

bosh2_cli_ok;

# Reused variables:
my $target_dir;
my $intended_target;
my $link_target;

qx(rm -rf t/tmp; mkdir -p t/tmp);
chdir "t/tmp";

run_fails "genesis init %thing", "`genesis init` doesn't like malformed repo names";
ok ! -d "#1-thing-deployments", "`genesis init` refused to create #1-thing-deployments/ directory";

runs_ok "genesis init random";
ok -d "random-deployments",                      "`genesis init` created the random-deployments/ directory";
ok -d "random-deployments/.genesis",             "`genesis init` created the .genesis/ sub-directory";
ok -f "random-deployments/.genesis/config",      "`genesis init` created the .genesis/config file";
ok -d "random-deployments/.genesis/bin",         "`genesis init` created the .genesis/bin sub-directory";
ok -f "random-deployments/.genesis/bin/genesis", "`genesis init` embedded a copy of the calling `genesis` script in .genesis/bin";
ok -f "random-deployments/README.md",            "`genesis init` created a README";
ok -d "random-deployments/dev",                  "`genesis init` created the dev/ directory, since -k was not given";

qx(rm -rf *-deployments/);
runs_ok "genesis init -k shield/0.1.0";
ok -d "shield-deployments",                      "`genesis init` created the random-deployments/ directory";
ok -d "shield-deployments/.genesis",             "`genesis init` created the .genesis/ sub-directory";
ok -f "shield-deployments/.genesis/config",      "`genesis init` created the .genesis/config file";
ok -d "shield-deployments/.genesis/bin",         "`genesis init` created the .genesis/bin sub-directory";
ok -f "shield-deployments/.genesis/bin/genesis", "`genesis init` embedded a copy of the calling `genesis` script in .genesis/bin";
ok -d "shield-deployments/.genesis/kits",        "`genesis init` created the .genesis/kits subdirectory";
ok -f "shield-deployments/.genesis/kits/shield-0.1.0.tar.gz", "`genesis init` embedded a copy of the shield v0.1.0 kit";
ok -f "shield-deployments/README.md",            "`genesis init` created a README";
ok ! -d "shield-deployments/dev",                "`genesis init` did not create the dev/ directory, since -k was given";
ok get_file("shield-deployments/.genesis/config") =~ /\ndeployment_type: shield($|\n)/s, "`genesis init` uses the correct deployment-type";
chdir("shield-deployments");
output_ok("git status --porcelain", "", "No untracked/changed files exist after a genesis init");
chdir("..");

qx(rm -rf *-deployments/);
runs_ok "genesis init -k shield/0.1.0 -d backups back-ups";
ok -d "backups",                      "`genesis init` created the backups/ directory";
ok -d "backups/.genesis",             "`genesis init` created the .genesis/ sub-directory";
ok -f "backups/.genesis/config",      "`genesis init` created the .genesis/config file";
ok -d "backups/.genesis/bin",         "`genesis init` created the .genesis/bin sub-directory";
ok -f "backups/.genesis/bin/genesis", "`genesis init` embedded a copy of the calling `genesis` script in .genesis/bin";
ok -d "backups/.genesis/kits",        "`genesis init` created the .genesis/kits subdirectory";
ok -f "backups/.genesis/kits/shield-0.1.0.tar.gz", "`genesis init` embedded a copy of the shield v0.1.0 kit";
ok -f "backups/README.md",            "`genesis init` created a README";
ok ! -d "backups/dev",                "`genesis init` did not create the dev/ directory, since -k was given";
ok get_file("backups/.genesis/config") =~ /\ndeployment_type: back-ups($|\n)/s, "`genesis init` uses the correct deployment-type";

qx(rm -rf backups);

run_fails "genesis init -k shield/0.1.0 -L ../kits/ask-params shouldfail", "`genesis init` fails when specifying both -k and -L";
qx(rm -rf shouldfail-deployments) if -d "shouldfail-deployments";

runs_ok "genesis init  -L ../kits/ask-params";
$target_dir = "ask-params-deployments";
ok -d "$target_dir", "`genesis init` with -L ask-params created the default directory";
ok -d "$target_dir/.genesis",                       "`genesis init` created the .genesis/ sub-directory";
ok -f "$target_dir/.genesis/config",                "`genesis init` created the .genesis/config file";
ok -d "$target_dir/.genesis/bin",                   "`genesis init` created the .genesis/bin sub-directory";
ok -f "$target_dir/.genesis/bin/genesis",           "`genesis init` embedded a copy of the calling `genesis` script in .genesis/bin";
ok ! -d "$target_dir/.genesis/kits",                "`genesis init` didn't create the .genesis/kits subdirectory";
ok -f "$target_dir/README.md",                      "`genesis init` created a README";
ok -d "$target_dir/dev" && -l "$target_dir/dev",     "`genesis init` created the dev/ directory as a link";
$intended_target = abs_path('../kits/ask-params');
$link_target = readlink("$target_dir/dev");
ok $link_target eq $intended_target,               "`genesis init` correctly linked to the intended target ('$link_target' == '$intended_target')";
ok get_file("$target_dir/.genesis/config") =~ /\ndeployment_type: ask-params($|\n)/s, "`genesis init` uses the correct deployment-type";
qx(rm -rf $target_dir) if -d "$target_dir";

runs_ok "genesis init  -L ../kits/ask-params mytest";
$target_dir = "mytest-deployments";
ok -d "$target_dir", "`genesis init` with -L ask-params created the my directory";
ok -d "$target_dir/.genesis",                       "`genesis init` created the .genesis/ sub-directory";
ok -f "$target_dir/.genesis/config",                "`genesis init` created the .genesis/config file";
ok -d "$target_dir/.genesis/bin",                   "`genesis init` created the .genesis/bin sub-directory";
ok -f "$target_dir/.genesis/bin/genesis",           "`genesis init` embedded a copy of the calling `genesis` script in .genesis/bin";
ok ! -d "$target_dir/.genesis/kits",                "`genesis init` didn't create the .genesis/kits subdirectory";
ok -f "$target_dir/README.md",                      "`genesis init` created a README";
ok -d "$target_dir/dev" && -l "$target_dir/dev",    "`genesis init` created the dev/ directory as a link";
$intended_target = abs_path('../kits/ask-params');
$link_target = readlink("$target_dir/dev");
ok $link_target eq $intended_target,               "`genesis init` correctly linked to the intended target ('$link_target' == '$intended_target')";
ok get_file("$target_dir/.genesis/config") =~ /\ndeployment_type: mytest($|\n)/s, "`genesis init` uses the correct deployment-type";
qx(rm -rf $target_dir) if -d "$target_dir";

run_fails "genesis init -L ../kits/notakit shouldfail", "`genesis init` fails when specifying a non-existing directory for -L argument";
qx(rm -rf shouldfail) if -d "shouldfail";

mkdir "random-deployments";
run_fails "genesis init random", "`genesis init` fails when the destination it would use already exists";

done_testing
