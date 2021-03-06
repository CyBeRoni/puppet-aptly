# == Class: aptly
#
# aptly is a swiss army knife for Debian repository management
#
# === Parameters
#
# [*package_ensure*]
#   Ensure parameter to pass to the package resource.
#   Default: present
#
# [*config*]
#   Hash of configuration options for `/etc/aptly.conf`.
#   See http://www.aptly.info/#configuration
#   Default: {}
#
# [*repo*]
#   Whether to configure an apt::source for `repo.aptly.info`.
#   You might want to disable this if/when you've mirrored that yourself.
#   Default: true
#
class aptly (
  $package_ensure = present,
  $config = {},
  $repo = true,
  $key_server = 'keys.gnupg.net',
) {

  validate_hash($config)
  validate_bool($repo)

  if $repo {
    apt::source { 'aptly':
      location    => 'http://repo.aptly.info',
      release     => 'squeeze',
      repos       => 'main',
      key_server  => $key_server,
      key         => '2A194991',
      include_src => false,
    }

    Apt::Source['aptly'] -> Package['aptly']
  }

  package { 'aptly':
    ensure  => $package_ensure,
  }

  file { '/etc/aptly.conf':
    ensure  => file,
    content => inline_template("<%= @config.to_pson %>\n"),
  }
}
