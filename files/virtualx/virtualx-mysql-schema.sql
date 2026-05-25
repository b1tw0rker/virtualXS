-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Erstellungszeit: 25. Mai 2026 um 13:55
-- Server-Version: 10.11.15-MariaDB
-- PHP-Version: 8.3.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `virtualx`
--
CREATE DATABASE IF NOT EXISTS `virtualx`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;



USE `virtualx`;


--
-- Datenbank: `virtualx`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `actions`
--

CREATE TABLE `actions` (
  `id` int(11) NOT NULL,
  `web_id` int(11) DEFAULT NULL,
  `virtualx_usr` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `zeit` varchar(255) DEFAULT NULL,
  `IP` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `domaininfos`
--

CREATE TABLE `domaininfos` (
  `id` int(11) NOT NULL,
  `web_id` int(11) DEFAULT NULL,
  `virtualx_usr` varchar(255) DEFAULT NULL,
  `apache` int(11) DEFAULT NULL,
  `lets_encrypt` varchar(255) DEFAULT NULL,
  `mysql` varchar(255) DEFAULT NULL,
  `webalizer` varchar(255) DEFAULT NULL,
  `webmin` varchar(255) DEFAULT NULL,
  `quota` varchar(255) DEFAULT NULL,
  `mail` varchar(255) DEFAULT NULL,
  `subdomain` varchar(255) DEFAULT NULL,
  `alias` blob DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `no_of_subdomains` varchar(255) DEFAULT NULL,
  `virtuelle_ftp` varchar(255) DEFAULT NULL,
  `createdate` varchar(255) DEFAULT NULL,
  `server` varchar(255) DEFAULT NULL,
  `artikelnummer` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `domains`
--

CREATE TABLE `domains` (
  `id` int(11) NOT NULL,
  `domainname` varchar(255) DEFAULT NULL,
  `user` varchar(255) DEFAULT NULL,
  `real_dom` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `dovecot`
--

CREATE TABLE `dovecot` (
  `id` int(11) NOT NULL,
  `userid` varchar(255) DEFAULT NULL,
  `domain` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `home` varchar(255) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `gid` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `passwd`
--

CREATE TABLE `passwd` (
  `id` int(11) NOT NULL,
  `dom_id` int(11) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `passwd` varchar(255) DEFAULT NULL,
  `rootdir` varchar(255) DEFAULT NULL,
  `status` char(1) NOT NULL DEFAULT 'A'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `passwd_logs`
--

CREATE TABLE `passwd_logs` (
  `id` int(11) NOT NULL,
  `msg` varchar(255) DEFAULT NULL,
  `user` varchar(255) DEFAULT NULL,
  `pid` varchar(255) DEFAULT NULL,
  `host` varchar(255) DEFAULT NULL,
  `rhost` varchar(255) DEFAULT NULL,
  `logtime` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `serveraliase`
--

CREATE TABLE `serveraliase` (
  `id` int(11) NOT NULL,
  `web_id` int(11) DEFAULT NULL,
  `virtualx_usr` varchar(255) DEFAULT NULL,
  `serveralias` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `virtualmails`
--

CREATE TABLE `virtualmails` (
  `id` int(11) NOT NULL,
  `web_id` varchar(255) DEFAULT NULL,
  `virtualx_usr` varchar(255) DEFAULT NULL,
  `domainname` varchar(255) DEFAULT NULL,
  `mail_address` varchar(255) DEFAULT NULL,
  `mailbox` text DEFAULT NULL,
  `ist_alias` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vsftpd_logs`
--

CREATE TABLE `vsftpd_logs` (
  `id` int(11) NOT NULL,
  `msg` text DEFAULT NULL,
  `user` varchar(50) DEFAULT NULL,
  `pid` int(11) DEFAULT NULL,
  `host` varchar(255) DEFAULT NULL,
  `logtime` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `actions`
--
ALTER TABLE `actions`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `domaininfos`
--
ALTER TABLE `domaininfos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `web_id` (`web_id`);

--
-- Indizes für die Tabelle `domains`
--
ALTER TABLE `domains`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `domainname` (`domainname`);

--
-- Indizes für die Tabelle `dovecot`
--
ALTER TABLE `dovecot`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `passwd`
--
ALTER TABLE `passwd`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indizes für die Tabelle `passwd_logs`
--
ALTER TABLE `passwd_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `serveraliase`
--
ALTER TABLE `serveraliase`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `virtualmails`
--
ALTER TABLE `virtualmails`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `mail_address` (`mail_address`);

--
-- Indizes für die Tabelle `vsftpd_logs`
--
ALTER TABLE `vsftpd_logs`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `actions`
--
ALTER TABLE `actions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `domaininfos`
--
ALTER TABLE `domaininfos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `domains`
--
ALTER TABLE `domains`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `dovecot`
--
ALTER TABLE `dovecot`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `passwd`
--
ALTER TABLE `passwd`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `passwd_logs`
--
ALTER TABLE `passwd_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `serveraliase`
--
ALTER TABLE `serveraliase`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `virtualmails`
--
ALTER TABLE `virtualmails`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `vsftpd_logs`
--
ALTER TABLE `vsftpd_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
