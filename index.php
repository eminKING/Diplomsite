<?php

// Получаем IP-адрес сервера из переменной $_SERVER
$ipAddress = $_SERVER['SERVER_ADDR'];

// Выводим IP-адрес
print 'Server IP Address: ' . $ipAddress;

// Выводим информацию о PHP
phpinfo();
