-- phpMyAdmin SQL Dump
-- version 4.6.6deb4
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 06, 2021 at 11:09 AM
-- Server version: 10.1.38-MariaDB-0+deb9u1
-- PHP Version: 7.0.33-0+deb9u3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `KS_Platform`
--

-- --------------------------------------------------------

--
-- Table structure for table `Achievements`
--

CREATE TABLE `Achievements` (
  `achievementId` int(11) NOT NULL,
  `expires` set('never','daily','weekly','monthly','season') NOT NULL DEFAULT 'never',
  `achievementName` char(255) NOT NULL,
  `achievementDesc` char(255) NOT NULL,
  `trustclient` tinyint(1) NOT NULL,
  `progressneeded` int(11) NOT NULL,
  `prizeSku` char(255) NOT NULL,
  `exp` int(11) NOT NULL,
  `precon` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `containers`
--

CREATE TABLE `containers` (
  `containerid` int(11) NOT NULL,
  `sku` varchar(255) NOT NULL,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `containers_data`
--

CREATE TABLE `containers_data` (
  `rowid` int(11) NOT NULL,
  `containerid` int(11) NOT NULL,
  `slot` int(11) NOT NULL,
  `weight` int(11) NOT NULL,
  `sku` varchar(255) NOT NULL,
  `cardtype` varchar(255) NOT NULL,
  `amount` int(11) NOT NULL,
  `rerolls` int(11) NOT NULL,
  `fallbacksku` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `fallbackamount` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `Decks`
--

CREATE TABLE `Decks` (
  `deckid` int(10) UNSIGNED NOT NULL,
  `deckname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `cards` text COLLATE utf8_unicode_ci NOT NULL,
  `eventid` int(11) NOT NULL,
  `ownerid` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  `formats` text COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `EventId` int(11) NOT NULL,
  `EventName` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `EntryFees` varchar(255) NOT NULL,
  `EventType` enum('Draft','Constructed') NOT NULL DEFAULT 'Draft',
  `Open` tinyint(1) NOT NULL DEFAULT '1',
  `OpenDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `CloseDate` datetime DEFAULT NULL,
  `gamesneeded` int(11) NOT NULL,
  `Packs` varchar(255) NOT NULL,
  `CardsPerPack` int(11) NOT NULL,
  `queuekey` varchar(255) NOT NULL,
  `0win` int(11) NOT NULL,
  `1win` int(11) NOT NULL,
  `2win` int(11) NOT NULL,
  `3win` int(11) NOT NULL,
  `4win` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Games`
--

CREATE TABLE `Games` (
  `gameId` int(11) NOT NULL,
  `eventId1` int(11) NOT NULL,
  `eventId2` int(11) NOT NULL,
  `startdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ended` tinyint(1) NOT NULL,
  `player1` int(11) NOT NULL,
  `player2` int(11) NOT NULL,
  `deck1` int(11) NOT NULL,
  `deck2` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Inventory`
--

CREATE TABLE `Inventory` (
  `rowid` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `sku` char(255) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `number` int(11) NOT NULL,
  `accountBound` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `levels`
--

CREATE TABLE `levels` (
  `level` int(11) NOT NULL,
  `exprequired` int(11) NOT NULL,
  `reward1` varchar(255) NOT NULL,
  `reward2` varchar(255) NOT NULL,
  `reward3` varchar(255) NOT NULL,
  `reward4` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `messageId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `message` varchar(255) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `playerAchievements`
--

CREATE TABLE `playerAchievements` (
  `rowid` int(11) NOT NULL,
  `achievementId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `progress` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Playerevents`
--

CREATE TABLE `Playerevents` (
  `rowid` int(11) NOT NULL,
  `playerid` int(11) NOT NULL,
  `eventid` int(11) NOT NULL,
  `games` int(11) NOT NULL DEFAULT '0',
  `played` varchar(255) NOT NULL DEFAULT '',
  `finished` tinyint(1) NOT NULL DEFAULT '0',
  `DeckId` int(11) NOT NULL DEFAULT '0',
  `DraftStatus` varchar(255) NOT NULL DEFAULT '',
  `Status` enum('Drafting','Playing','Queued','Entered') NOT NULL DEFAULT 'Playing',
  `gamesneeded` int(11) NOT NULL DEFAULT '0',
  `gamesplayed` int(11) NOT NULL DEFAULT '0',
  `wins` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `prizes`
--

CREATE TABLE `prizes` (
  `prizeid` int(11) NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `prize_data`
--

CREATE TABLE `prize_data` (
  `rowid` int(11) NOT NULL,
  `prizeid` int(11) NOT NULL,
  `slot1` varchar(255) NOT NULL,
  `slot2` varchar(255) NOT NULL,
  `slot3` varchar(255) NOT NULL,
  `slot4` varchar(255) NOT NULL,
  `slot5` varchar(255) NOT NULL,
  `slot6` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `queue`
--

CREATE TABLE `queue` (
  `rowid` int(11) NOT NULL,
  `queuekey` varchar(255) NOT NULL,
  `playerid` int(11) NOT NULL,
  `deckid` int(11) NOT NULL,
  `eventid` int(11) NOT NULL,
  `jointime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `sessionId`
--

CREATE TABLE `sessionId` (
  `session` char(50) NOT NULL,
  `userId` int(11) NOT NULL,
  `logindate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `sku`
--

CREATE TABLE `sku` (
  `sku` char(255) NOT NULL,
  `description` char(255) NOT NULL,
  `alwaysBind` tinyint(1) NOT NULL,
  `card` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `templates`
--

CREATE TABLE `templates` (
  `templateid` int(10) UNSIGNED ZEROFILL NOT NULL,
  `name` varchar(255) NOT NULL,
  `html` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `UserLogin`
--

CREATE TABLE `UserLogin` (
  `userId` int(11) NOT NULL,
  `email` char(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `Users`
--

CREATE TABLE `Users` (
  `userId` int(11) NOT NULL,
  `username` char(255) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `password` char(255) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `verified` tinyint(1) NOT NULL,
  `code` char(255) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `permissions` int(11) DEFAULT '1',
  `level` int(11) NOT NULL DEFAULT '1',
  `currentexp` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Achievements`
--
ALTER TABLE `Achievements`
  ADD PRIMARY KEY (`achievementId`);

--
-- Indexes for table `containers`
--
ALTER TABLE `containers`
  ADD PRIMARY KEY (`containerid`);

--
-- Indexes for table `containers_data`
--
ALTER TABLE `containers_data`
  ADD PRIMARY KEY (`rowid`),
  ADD KEY `containerid` (`containerid`);

--
-- Indexes for table `Decks`
--
ALTER TABLE `Decks`
  ADD PRIMARY KEY (`deckid`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`EventId`);

--
-- Indexes for table `Games`
--
ALTER TABLE `Games`
  ADD PRIMARY KEY (`gameId`);

--
-- Indexes for table `Inventory`
--
ALTER TABLE `Inventory`
  ADD PRIMARY KEY (`rowid`),
  ADD KEY `userId` (`userId`);

--
-- Indexes for table `levels`
--
ALTER TABLE `levels`
  ADD PRIMARY KEY (`level`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`messageId`),
  ADD KEY `userId` (`userId`);

--
-- Indexes for table `playerAchievements`
--
ALTER TABLE `playerAchievements`
  ADD PRIMARY KEY (`rowid`),
  ADD UNIQUE KEY `unique` (`achievementId`,`userId`) USING BTREE;

--
-- Indexes for table `Playerevents`
--
ALTER TABLE `Playerevents`
  ADD PRIMARY KEY (`rowid`);

--
-- Indexes for table `prizes`
--
ALTER TABLE `prizes`
  ADD PRIMARY KEY (`prizeid`);

--
-- Indexes for table `prize_data`
--
ALTER TABLE `prize_data`
  ADD PRIMARY KEY (`rowid`),
  ADD KEY `prizeid` (`prizeid`);

--
-- Indexes for table `queue`
--
ALTER TABLE `queue`
  ADD PRIMARY KEY (`rowid`),
  ADD KEY `queuekey` (`queuekey`(191));

--
-- Indexes for table `sessionId`
--
ALTER TABLE `sessionId`
  ADD PRIMARY KEY (`session`);

--
-- Indexes for table `sku`
--
ALTER TABLE `sku`
  ADD PRIMARY KEY (`sku`);

--
-- Indexes for table `templates`
--
ALTER TABLE `templates`
  ADD PRIMARY KEY (`templateid`);

--
-- Indexes for table `UserLogin`
--
ALTER TABLE `UserLogin`
  ADD PRIMARY KEY (`userId`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `Users`
--
ALTER TABLE `Users`
  ADD PRIMARY KEY (`userId`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Achievements`
--
ALTER TABLE `Achievements`
  MODIFY `achievementId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `containers`
--
ALTER TABLE `containers`
  MODIFY `containerid` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `containers_data`
--
ALTER TABLE `containers_data`
  MODIFY `rowid` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `Decks`
--
ALTER TABLE `Decks`
  MODIFY `deckid` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=120;
--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `EventId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `Games`
--
ALTER TABLE `Games`
  MODIFY `gameId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=189;
--
-- AUTO_INCREMENT for table `Inventory`
--
ALTER TABLE `Inventory`
  MODIFY `rowid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=140;
--
-- AUTO_INCREMENT for table `levels`
--
ALTER TABLE `levels`
  MODIFY `level` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `messageId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1389;
--
-- AUTO_INCREMENT for table `playerAchievements`
--
ALTER TABLE `playerAchievements`
  MODIFY `rowid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=410;
--
-- AUTO_INCREMENT for table `Playerevents`
--
ALTER TABLE `Playerevents`
  MODIFY `rowid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;
--
-- AUTO_INCREMENT for table `prizes`
--
ALTER TABLE `prizes`
  MODIFY `prizeid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `prize_data`
--
ALTER TABLE `prize_data`
  MODIFY `rowid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `queue`
--
ALTER TABLE `queue`
  MODIFY `rowid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT for table `templates`
--
ALTER TABLE `templates`
  MODIFY `templateid` int(10) UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `UserLogin`
--
ALTER TABLE `UserLogin`
  MODIFY `userId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=131;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
