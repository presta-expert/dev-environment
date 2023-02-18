<?php

require_once __DIR__ . '/../../config/config.inc.php';

Configuration::updateValue('PS_MAIL_METHOD', Mail::METHOD_SMTP);
Configuration::updateValue('PS_MAIL_SERVER', 'mailhog');
Configuration::updateValue('PS_MAIL_SMTP_PORT', 1025);
