# == Define: aptly::repo
#
# Create a repository using `aptly create`. It will not snapshot, or update the
# repository for you, because it will take a long time and it doesn't make sense
# to schedule these actions frequently in Puppet.
#
# === Parameters
#
# [*component*]
#   Specify which component to put the package in. This option will only works
#   for aptly version >= 0.5.0.
# [*distribution*]
#   The distribution for publishing. Required when publishing.
# [*prefix*]
#   The prefix when publishing, defaults to '.'
# [*publish*]
#   Whether or not to publish the repo, defaults to false.
# [*keyring*]
#   The GPG keyring to get the public key from. Optional.
# [*secring*]
#   The GPG keyring to get the secret key from. Optional.
#
define aptly::repo (
  $component = '',
  $distribution = '',
  $prefix = '.',
  $publish = false,
  $keyring = '',
  $secring = '',
){
  validate_string($component)

  $aptly_cmd = '/usr/bin/aptly'

  if empty($component) {
    $component_arg = ''
  } else{
    $component_arg = "-component='${component}'"
  }

  exec {"aptly_repo_create-${title}":
    command => "${aptly_cmd} repo create ${component_arg} ${title}",
    unless  => "${aptly_cmd} repo show ${title} >/dev/null",
    user    => 'root',
    require => [
      Class['aptly'],
    ],
  }

  if $publish {
    if empty($distribution){
      $distribution_arg = ''
    } else {
      $distribution_arg = "-distribution='${distribution}'"
    }

    if empty($keyring){
      $keyring_arg = ''
    } else {
      $keyring_arg = "-keyring='${keyring}'"
    }

    if empty($secring){
      $secring_arg = ''
    } else {
      $secring_arg = "-secret-keyring='${secring}'"
    }

    exec {"aptly_publish_repo-${title}":
      command => "${aptly_cmd} publish ${keyring_arg} ${secring_arg} ${distribution_arg} repo ${title} ${prefix}",
      unless  => "${aptly_cmd} publish list -raw | grep '${prefix} ${distribution}'",
      user    => 'root',
      require => [
        Class['aptly'],
        File[$keyring, $secring],
      ]
    }
  }

}
