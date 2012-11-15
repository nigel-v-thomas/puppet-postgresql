define postgresql::db (
    $password,
    $owner = $name,
    $encoding = 'UTF8',
    $locale = 'en_US.UTF-8',
    $template = 'template0',
) {

    pg_user {$owner:
        ensure      => present,
        password    => $password,
        require => Service['postgresql'],
    }

    pg_database {$name:
        ensure      => present,
        owner       => $owner,
        require     => [Pg_user[$owner], Service['postgresql-8.4']],
        encoding    => $encoding,
        locale      => $locale,
        template    => $template,
    }
}
