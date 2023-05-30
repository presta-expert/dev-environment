# CHANGELOG

## 1.1.1 (2023-05-30)

- Fixed `apt update` problem due to debian has moved stretch repositories to archive.debian.org

## 1.1.0 (2023-02-18)

- Configured automatic sending of all e-mails from the store via MailHog SMTP. [[Issue #1]](https://github.com/presta-expert/dev-environment/issues/1)
- Fixed `mhsendmail` to work automatically with the php _mail()_ function. [[Issue #1]](https://github.com/presta-expert/dev-environment/issues/1)
- We're now checking if sub-command `docker compose` exists, and we use `docker-compose` otherwise. [[Issue #2]](https://github.com/presta-expert/dev-environment/issues/2)
- Permissions fix will now take place only once instead of running it with every `bin/dev.sh up`
- Updated README

## 1.0.0 (2023-01-26)

- Initial release
