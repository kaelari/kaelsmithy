-- phpMyAdmin SQL Dump
-- version 4.6.6deb4
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 06, 2021 at 11:10 AM
-- Server version: 10.1.38-MariaDB-0+deb9u1
-- PHP Version: 7.0.33-0+deb9u3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `KS_cards`
--

-- --------------------------------------------------------

--
-- Table structure for table `Activated`
--

CREATE TABLE `Activated` (
  `ActivateId` int(11) NOT NULL,
  `targettype` varchar(255) NOT NULL,
  `targetindex` varchar(255) NOT NULL,
  `effects` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `Activated`
--

INSERT INTO `Activated` (`ActivateId`, `targettype`, `targetindex`, `effects`) VALUES
(1, 'single', '1,12', '54,55'),
(2, 'single', '1,13', '54,55'),
(3, 'single', '1,14', '54,55'),
(4, 'Ship', '1', '64'),
(5, 'Ship', '1', '65'),
(6, 'Ship', '1', '66'),
(7, 'allcards', '20', '67'),
(8, 'allcards', '21', '67'),
(9, 'allcards', '22', '67'),
(10, 'Ship', '5', '80'),
(11, 'Ship', '5', '81'),
(12, 'Ship', '5', '82'),
(13, 'single', '38', '92');

-- --------------------------------------------------------

--
-- Table structure for table `carddata`
--

CREATE TABLE `carddata` (
  `CardId` int(20) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `levelsto` int(11) NOT NULL,
  `levels from` int(11) NOT NULL,
  `level` tinyint(4) NOT NULL,
  `CardType` enum('Ship','Effect','Station','Weapon') NOT NULL DEFAULT 'Ship',
  `cost` tinyint(4) NOT NULL DEFAULT '1',
  `subtype` varchar(255) NOT NULL,
  `Text` text NOT NULL,
  `Cardart` varchar(50) NOT NULL,
  `Tooltips` varchar(255) NOT NULL,
  `Attack` int(11) NOT NULL,
  `Health` int(11) NOT NULL,
  `FlavorText` varchar(255) NOT NULL,
  `Faction` enum('Earth','Mars','Helkinite','Dralk') NOT NULL,
  `rarity` enum('Common','Rare','Hero','Mythical','Token') NOT NULL DEFAULT 'Common',
  `keywords` varchar(255) NOT NULL,
  `basestatic` varchar(255) NOT NULL,
  `basetriggers` varchar(255) NOT NULL,
  `activated` varchar(255) NOT NULL,
  `targets` varchar(255) NOT NULL,
  `effects` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `carddata`
--

INSERT INTO `carddata` (`CardId`, `Name`, `levelsto`, `levels from`, `level`, `CardType`, `cost`, `subtype`, `Text`, `Cardart`, `Tooltips`, `Attack`, `Health`, `FlavorText`, `Faction`, `rarity`, `keywords`, `basestatic`, `basetriggers`, `activated`, `targets`, `effects`) VALUES
(43, 'Alpha Fighter', 44, 0, 1, 'Ship', 1, 'Fighter', '', 'ship1', '', 5, 5, '', 'Earth', 'Common', '', '', '', '', '', ''),
(44, 'Alpha Fighter', 45, 43, 2, 'Ship', 1, 'Fighter', '', 'ship1', '', 10, 10, '', 'Earth', 'Common', '', '', '', '', '', ''),
(45, 'Alpha Fighter', 45, 44, 3, 'Ship', 1, 'Fighter', '', 'ship1', '', 15, 15, '', 'Earth', 'Common', '', '', '', '', '', ''),
(46, 'Enlarge', 47, 0, 1, 'Effect', 1, '', 'Target Ship gets +3/+3', 'shrink', '', 0, 0, '', 'Helkinite', 'Common', '', '', '', '', '1', '1'),
(47, 'Enlarge', 48, 45, 2, 'Effect', 1, '', 'Target Ship gets +6/+6', 'shrink', '', 0, 0, '', 'Helkinite', 'Common', '', '', '', '', '1', '2'),
(48, 'Enlarge', 48, 46, 3, 'Effect', 1, '', 'Target Ship gets +12/+12', 'shrink', '', 0, 0, '', 'Helkinite', 'Common', '', '', '', '', '1', '3'),
(49, 'Beta Assassin', 50, 0, 1, 'Ship', 1, 'Assassin', '', 'academy', '', 4, 5, '', 'Mars', 'Common', '', '', '', '', '', ''),
(50, 'Beta Assassin', 51, 49, 2, 'Ship', 1, 'Assassin', '', 'academy', '', 12, 11, '', 'Mars', 'Common', '', '', '', '', '', ''),
(51, 'Beta Assassin', 51, 50, 3, 'Ship', 1, 'Assassin', '', 'academy', '', 15, 14, '', 'Mars', 'Common', '', '', '', '', '', ''),
(52, 'Armor Bot', 53, 0, 1, 'Ship', 1, 'Robot', 'When you play this give a friendly ship +0/+2', 'block', '', 5, 4, '', 'Mars', 'Common', '', '', '1', '', '', ''),
(53, 'Armor Bot', 54, 52, 2, 'Ship', 1, 'Robot', 'When you play this give a friendly ship +0/+4', 'block', '', 9, 8, '', 'Mars', 'Common', '', '', '2', '', '', ''),
(54, 'Armor Bot', 54, 53, 3, 'Ship', 1, 'Robot', 'When you play this give a friendly ship +0/+6', 'block', '', 13, 12, '', 'Mars', 'Common', '', '', '3', '', '', ''),
(55, 'Target Aid', 56, 0, 1, 'Ship', 1, 'Support', 'When you play this give a friendly ship +3 attack', 'barrage', '', 3, 3, '', 'Earth', 'Common', '', '', '4', '', '', ''),
(56, 'Target Aid', 57, 55, 2, 'Ship', 1, 'Support', 'When you play this give a friendly ship +6 attack', 'barrage', '', 8, 8, '', 'Earth', 'Common', '', '', '5', '', '', ''),
(57, 'Target Aid', 57, 56, 3, 'Ship', 1, 'Support', 'When you play this give a friendly ship +9 attack', 'barrage', '', 12, 12, '', 'Earth', 'Common', '', '', '6', '', '', ''),
(58, 'Foresight', 59, 0, 1, 'Effect', 1, '', 'Draw a card', '', '', 0, 0, '', 'Earth', 'Common', '', '', '', '', '2', '10'),
(59, 'Foresight', 60, 58, 2, 'Effect', 0, '', 'Draw two cards', '', '', 0, 0, '', 'Earth', 'Common', 'Free', '', '', '', '2', '10,10'),
(60, 'Foresight', 60, 59, 3, 'Effect', 0, '', 'Draw three cards', '', '', 0, 0, '', 'Earth', 'Common', 'Free', '', '', '', '2', '10,10,10'),
(61, 'Prowler', 62, 0, 1, 'Ship', 1, 'Prowler', '', 'blue', '', 8, 7, '', 'Helkinite', 'Common', 'Relentless', '', '', '', '', ''),
(62, 'Prowler', 63, 61, 2, 'Ship', 1, 'Prowler', '', 'blue', '', 9, 8, '', 'Helkinite', 'Common', 'Relentless', '', '', '', '', ''),
(63, 'Prowler', 63, 62, 3, 'Ship', 1, 'Prowler', '', 'blue', '', 10, 9, '', 'Helkinite', 'Common', 'Relentless', '', '', '', '', ''),
(64, 'Lancer', 65, 0, 1, 'Ship', 1, 'Lancer', '', 'battleship', '', 6, 4, '', 'Earth', 'Common', '', '', '', '', '', ''),
(65, 'Lancer', 66, 64, 2, 'Ship', 1, 'Lancer', '', 'battleship', '', 12, 6, '', 'Earth', 'Common', '', '', '', '', '', ''),
(66, 'Lancer', 66, 65, 3, 'Ship', 1, 'Lancer', '', 'battleship', '', 18, 9, '', 'Earth', 'Common', '', '', '', '', '', ''),
(67, 'Slayer', 68, 0, 1, 'Ship', 1, 'Warship', '', 'center', '', 6, 6, '', 'Helkinite', 'Common', '', '', '', '', '', ''),
(68, 'Slayer', 69, 67, 2, 'Ship', 1, 'Warship', '', 'center', '', 10, 10, '', 'Helkinite', 'Common', '', '', '', '', '', ''),
(69, 'Slayer', 69, 68, 3, 'Ship', 1, 'Warship', '', 'center', '', 16, 16, '', 'Helkinite', 'Common', '', '', '', '', '', ''),
(70, 'Support Frigate', 71, 0, 1, 'Ship', 1, 'Frigate', 'When you play this give a friendly ship +1/+1', 'commandpod', '', 4, 5, '', 'Helkinite', 'Common', '', '', '7', '', '', ''),
(71, 'Support Frigate', 72, 70, 2, 'Ship', 1, 'Frigate', 'When you play this, give a friendly ship +3/+3', 'commandpod', '', 4, 9, '', 'Helkinite', 'Common', '', '', '8', '', '', ''),
(72, 'Support Frigate', 72, 71, 3, 'Ship', 1, 'Frigate', 'When you play this, give a friendly ship +5/+5', 'commandpod', '', 9, 15, '', 'Helkinite', 'Common', '', '', '9', '', '', ''),
(73, 'Potential', 74, 0, 1, 'Ship', 1, 'Project', '', 'tekhir', '', 3, 3, '', 'Earth', 'Common', '', '', '', '', '', ''),
(74, 'Potential', 75, 73, 2, 'Ship', 1, 'Project', '', 'tekhir', '', 7, 7, '', 'Earth', 'Common', '', '', '', '', '', ''),
(75, 'Potential', 75, 74, 3, 'Ship', 1, 'Project', '', 'tekhir', '', 20, 20, '', 'Earth', 'Common', 'Relentless', '', '', '', '', ''),
(76, 'Dead End', 77, 0, 1, 'Ship', 1, 'Tree', '', 'sideview', '', 7, 7, '', 'Helkinite', 'Common', '', '', '', '', '', ''),
(77, 'Dead End', 0, 76, 2, 'Ship', 1, 'Tree', '', 'sideview', '', 13, 13, '', 'Helkinite', 'Common', '', '', '', '', '', ''),
(78, 'Research Vessel', 79, 0, 1, 'Ship', 1, 'Science', 'At the start of your turn draw a card', 'vortexrider', '', 3, 7, '', 'Earth', 'Mythical', '', '', '10', '', '', ''),
(79, 'Research Vessel', 80, 78, 2, 'Ship', 1, 'Science', 'At the start of your turn draw two cards', 'vortexrider', '', 6, 12, '', 'Earth', 'Mythical', '', '', '11', '', '', ''),
(80, 'Research Vessel', 80, 79, 3, 'Ship', 1, 'Science', 'At the start of your turn draw three cards', 'vortexrider', '', 11, 18, '', 'Earth', 'Mythical', '', '', '12', '', '', ''),
(81, 'Research Bot', 82, 0, 1, 'Ship', 1, 'Robot', 'When this is played discard and level a card in your hand.', 'Vortexcorvette', '', 3, 3, '', 'Earth', 'Common', '', '', '13', '', '', ''),
(82, 'Research Bot', 83, 81, 2, 'Ship', 1, 'Robot', 'When this is played discard and level a card in your hand.', 'Vortexcorvette', '', 7, 8, '', 'Earth', 'Common', '', '', '13', '', '', ''),
(83, 'Research Bot', 83, 82, 3, 'Ship', 1, 'Robot', 'When this is played discard and level a card in your hand.', 'Vortexcorvette', '', 14, 14, '', 'Earth', 'Common', '', '', '13', '', '', ''),
(84, 'Spewing Monstrosity', 85, 0, 1, 'Ship', 1, 'Artillery', 'At the start of your turn deal 2 damage to each opponent', 'rager', '', 5, 5, '', 'Mars', 'Common', '', '', '14', '', '', ''),
(85, 'Spewing Monstrosity', 86, 84, 2, 'Ship', 1, 'Artillery', 'At the start of your turn deal 4 damage to each opponent', 'rager', '', 10, 10, '', 'Mars', 'Common', '', '', '15', '', '', ''),
(86, 'Spewing Monstrosity', 86, 85, 3, 'Ship', 1, 'Artillery', 'At the start of your turn deal 6 damage to each opponent', 'rager', '', 15, 15, '', 'Mars', 'Common', '', '', '16', '', '', ''),
(87, 'Restorative Monstrosity', 88, 0, 1, 'Ship', 1, 'Medic', 'At the start of your turn gain 2 life', 'lightcarrier', '', 5, 5, '', 'Helkinite', 'Common', '', '', '17', '', '', ''),
(88, 'Restorative Monstrosity', 89, 87, 2, 'Ship', 1, 'Medic', 'At the start of your turn gain 4 life', 'lightcarrier', '', 10, 10, '', 'Helkinite', 'Common', '', '', '18', '', '', ''),
(89, 'Restorative Monstrosity', 89, 88, 3, 'Ship', 1, 'Medic', 'At the start of your turn gain 6 life', 'lightcarrier', '', 15, 15, '', 'Helkinite', 'Common', '', '', '19', '', '', ''),
(90, 'Lifeforce researcher', 91, 0, 1, 'Ship', 1, 'Science', 'When you gain life draw a card', 'miningrig', '', 4, 4, '', 'Helkinite', 'Common', '', '', '20', '', '', ''),
(91, 'Lifeforce researcher', 92, 90, 2, 'Ship', 1, 'Science', 'When you gain life draw a card', 'miningrig', '', 9, 9, '', 'Helkinite', 'Common', '', '', '20', '', '', ''),
(92, 'Lifeforce researcher', 92, 91, 3, 'Ship', 1, 'Science', 'When you gain life draw a card', 'miningrig', '', 17, 17, '', 'Helkinite', 'Common', '', '', '20', '', '', ''),
(93, 'Medical Vessel', 94, 0, 1, 'Ship', 1, 'Medic', 'When this is played gain 5 life', 'shipofline', '', 3, 5, '', 'Helkinite', 'Common', '', '', '21', '', '', ''),
(94, 'Medical Vessel', 95, 93, 2, 'Ship', 1, 'Medic', 'When this is played gain 10 life', 'shipofline', '', 6, 11, '', 'Helkinite', 'Common', '', '', '22', '', '', ''),
(95, 'Medical Vessel', 95, 94, 3, 'Ship', 1, 'Medic', 'When this is played gain 15 life', 'shipofline', '', 12, 18, '', 'Helkinite', 'Common', '', '', '23', '', '', ''),
(96, 'Patrol Ship', 0, 0, 1, 'Ship', 1, 'Fighter', '', '', '', 3, 3, '', 'Helkinite', 'Token', '', '', '', '', '', ''),
(97, 'Patrol Ship', 0, 0, 2, 'Ship', 1, 'Fighter', '', '', '', 5, 5, '', 'Helkinite', 'Token', '', '', '', '', '', ''),
(98, 'Patrol Ship', 0, 0, 3, 'Ship', 1, 'Fighter', '', '', '', 8, 8, '', 'Helkinite', 'Token', '', '', '', '', '', ''),
(99, 'Lifeforce Carrier', 100, 0, 1, 'Ship', 1, 'carrier', 'When you gain life summon a 3/3 patrolship in a random empty lane.', 'block', '', 4, 6, '', 'Helkinite', 'Rare', '', '', '24', '', '', ''),
(100, 'Lifeforce Carrier', 101, 99, 2, 'Ship', 1, 'carrier', 'When you gain life summon a 5/5 patrolship in a random empty lane.', 'block', '', 8, 12, '', 'Helkinite', 'Rare', '', '', '25', '', '', ''),
(101, 'Lifeforce Carrier', 101, 100, 3, 'Ship', 1, 'carrier', 'When you gain life summon a 8/8 patrolship in a random empty lane.', 'block', '', 12, 16, '', 'Helkinite', 'Rare', '', '', '26', '', '', ''),
(102, 'Witherbeam Cruiser', 103, 0, 1, 'Ship', 1, 'Witherbeam', 'When you play this give an enemy ship -2/-2', 'shooting', '', 4, 5, '', 'Dralk', 'Common', '', '', '27', '', '', ''),
(103, 'Witherbeam Cruiser', 104, 102, 2, 'Ship', 1, 'Witherbeam', 'When you play this give an enemy ship -4/-4', 'shooting', '', 8, 9, '', 'Dralk', 'Common', '', '', '28', '', '', ''),
(104, 'Witherbeam Cruiser', 104, 103, 3, 'Ship', 1, 'Wtiherbeam', 'When you play this give an enemy ship -6/-6', 'shooting', '', 13, 16, '', 'Dralk', 'Common', '', '', '29', '', '', ''),
(105, 'Withering Ripple', 106, 0, 1, 'Effect', 1, '', 'All enemy ships get -3/-3', 'plasma', '', 0, 0, '', 'Dralk', 'Common', '', '', '', '', '4', '18'),
(106, 'Withering Ripple', 107, 105, 2, 'Effect', 1, '', 'All enemy ships get -5/-5', 'plasma', '', 0, 0, '', 'Dralk', 'Common', '', '', '', '', '4', '19'),
(107, 'Withering Ripple', 107, 106, 3, 'Effect', 1, '', 'All enemy ships get -7/-7', 'plasma', '', 0, 0, '', 'Dralk', 'Common', '', '', '', '', '4', '20'),
(108, 'Death\'s Apprentice', 109, 0, 1, 'Ship', 1, 'Escape Pod', 'When this dies create a 4/6 ghost', 'lightfighter', '', 1, 1, '', 'Dralk', 'Common', '', '', '30', '', '', ''),
(109, 'Death\'s Apprentice', 110, 108, 2, 'Ship', 1, 'Escape Pod', 'When this dies create a 8/12 ghost', 'lightfighter', '', 1, 1, '', 'Dralk', 'Common', '', '', '31', '', '', ''),
(110, 'Death\'s Apprentice', 110, 109, 3, 'Ship', 1, 'Escape Pod', 'When this dies create a 12/18 ghost', 'lightfighter', '', 1, 1, '', 'Dralk', 'Common', '', '', '32', '', '', ''),
(111, 'Spirit of the Fallen', 0, 0, 1, 'Ship', 1, 'Ghost', '', '', '', 4, 6, '', 'Dralk', 'Token', '', '', '', '', '', ''),
(112, 'Spirit of the Fallen', 0, 0, 2, 'Ship', 1, 'Ghost', '', '', '', 8, 12, '', 'Dralk', 'Token', '', '', '', '', '', ''),
(113, 'Spirit of the Fallen', 0, 0, 3, 'Ship', 1, 'Ghost', '', '', '', 12, 18, '', 'Dralk', 'Token', '', '', '', '', '', ''),
(114, 'Doomwake Gargantuan', 115, 0, 1, 'Ship', 1, 'Doomwake', 'When this dies opponent loses 3 life', 'warpdestroyer', '', 7, 3, '', 'Dralk', 'Common', '', '', '33', '', '', ''),
(115, 'Doomwake Gargantuan', 116, 114, 2, 'Ship', 1, 'Doomwake', 'When this dies opponent loses 6 life', 'warpdestroyer', '', 12, 6, '', 'Dralk', 'Common', '', '', '34', '', '', ''),
(116, 'Doomwake Gargantuan', 116, 115, 3, 'Ship', 1, 'Doomwake', 'When this dies opponent loses 9 life', 'warpdestroyer', '', 18, 12, '', 'Dralk', 'Common', '', '', '35', '', '', ''),
(117, 'Doomwake Controller', 118, 0, 1, 'Ship', 1, 'Doomwake', 'When this or another doomwake is played opponent takes 2 damage', '', '', 6, 4, '', 'Dralk', 'Common', '', '', '36', '', '', ''),
(118, 'Doomwake Controller', 119, 117, 2, 'Ship', 1, 'Doomwake', 'When this or another doomwake is played opponent takes 3 damage', '', '', 11, 7, '', 'Dralk', 'Common', '', '', '37', '', '', ''),
(119, 'Doomwake Controller', 119, 118, 3, 'Ship', 1, 'Doomwake', 'When this or another doomwake is played opponent takes 4 damage', '', '', 15, 13, '', 'Dralk', 'Common', '', '', '38', '', '', ''),
(120, 'Doomwake Amplifier', 121, 0, 1, 'Ship', 1, 'Doomwake', 'When another doomwake dies deal 2 damage to the opponent', '', '', 8, 1, '', 'Dralk', 'Common', '', '', '39', '', '', ''),
(121, 'Doomwake Amplifier', 122, 120, 2, 'Ship', 1, 'Doomwake', 'When another doomwake dies deal 3 damage to the opponent', '', '', 13, 3, '', 'Dralk', 'Common', '', '', '40', '', '', ''),
(122, 'Doomwake Amplifier', 122, 121, 3, 'Ship', 1, 'Doomwake', 'When another doomwake dies deal 4 damage to the opponent', '', '', 16, 6, '', 'Dralk', 'Common', '', '', '41', '', '', ''),
(123, 'Factory Ship', 124, 0, 1, 'Ship', 1, 'Constructor', '', '', '', 3, 5, '', 'Helkinite', 'Rare', '', '', '', '', '', ''),
(124, 'Factory Ship', 125, 123, 2, 'Ship', 1, 'Constructor', 'When this is played a level 1 ship in your hand gains \"Free\".', '', '', 7, 9, '', 'Helkinite', 'Rare', '', '', '42', '', '', ''),
(125, 'Factory Ship', 125, 124, 3, 'Ship', 1, 'Constructor', 'When this is played a level 2 or lower ship in your hand gains \"Free\".', '', '', 13, 14, '', 'Helkinite', 'Rare', '', '', '43', '', '', ''),
(126, 'Artillery Blast', 127, 0, 1, 'Effect', 1, '', 'Deal 5 damage to an enemy ship and your opponent', '', '', 0, 0, '', 'Mars', 'Rare', '', '', '', '', '5', '23,22'),
(127, 'Artillery Blast', 128, 126, 2, 'Effect', 1, '', 'Deal 10 damage to an enemy ship and your opponent', '', '', 0, 0, '', 'Mars', 'Rare', '', '', '', '', '5', '24,25'),
(128, 'Artillery Blast', 128, 127, 3, 'Effect', 1, '', 'Deal 15 damage to an enemy ship and your opponent', '', '', 0, 0, '', 'Mars', 'Rare', '', '', '', '', '5', '26,27'),
(130, 'Draining Burst', 131, 0, 1, 'Effect', 1, '', 'A ship you control gets +3 attack, a ship you don\'t control gets -3 attack.', '', '', 0, 0, '', 'Earth', 'Common', '', '', '', '', '1,5', '28,29'),
(131, 'Draining Burst', 132, 129, 2, 'Effect', 1, '', 'A ship you control gets +6 attack, a ship you don\'t control gets -6 attack.', '', '', 0, 0, '', 'Earth', 'Common', '', '', '', '', '1,5', '30,31'),
(132, 'Draining Burst', 132, 130, 3, 'Effect', 1, '', 'A ship you control gets +8 attack, a ship you don\'t control gets -8 attack.', '', '', 0, 0, '', 'Earth', 'Common', '', '', '', '', '1,5', '32,33'),
(133, 'Reinforcement Wave', 134, 0, 1, 'Effect', 1, '', 'Give all friendly creatures +3/+3', '', '', 0, 0, '', 'Helkinite', 'Hero', '', '', '', '', '7', '34'),
(134, 'Reinforcement Wave', 135, 133, 2, 'Effect', 1, '', 'Give all friendly creatures +5/+5', '', '', 0, 0, '', 'Helkinite', 'Hero', '', '', '', '', '7', '35'),
(135, 'Reinforcement Wave', 135, 134, 3, 'Effect', 1, '', 'Give all friendly creatures +7/+7 and Relentless', '', '', 0, 0, '', 'Helkinite', 'Hero', '', '', '', '', '7', '36,37'),
(136, 'Release Potential', 0, 0, 1, 'Effect', 1, '', 'Give a ship +6/+6 and relentless', '', '', 0, 0, '', 'Helkinite', 'Hero', 'One-Shot', '', '', '', '1', '38,39'),
(137, 'Release Destruction', 0, 0, 1, 'Effect', 1, '', 'Deal 8 damage to two enemy ships', '', '', 0, 0, '', 'Mars', 'Hero', 'One-Shot', '', '', '', '5,5', '40,41'),
(138, 'Release Withering', 0, 0, 1, 'Effect', 1, '', 'Two enemy ships get -4/-4', '', '', 0, 0, '', 'Dralk', 'Hero', 'One-Shot', '', '', '', '5,5', '42,43'),
(139, 'Release Destiny', 0, 0, 1, 'Effect', 1, '', 'Discard and level two cards in your hand', '', '', 0, 0, '', 'Earth', 'Hero', 'One-Shot', '', '', '', '3,3', '44,45'),
(140, 'Regenerative Mass', 141, 0, 1, 'Ship', 1, 'Mass', '', '', '', 2, 7, '', 'Dralk', 'Common', 'Repair 5', '', '', '', '', ''),
(141, 'Regenerative Mass', 142, 140, 2, 'Ship', 1, 'Mass', '', '', '', 6, 13, '', 'Dralk', 'Common', 'Repair 5', '', '', '', '', ''),
(142, 'Regenerative Mass', 142, 141, 3, 'Ship', 1, 'Mass', '', '', '', 12, 17, '', 'Dralk', 'Common', 'Repair 5', '', '', '', '', ''),
(143, 'Missile Cruiser', 144, 0, 1, 'Ship', 1, 'Cruiser', 'When you play this deal 2 damage to an enemy ship', '', '', 4, 3, '', 'Mars', 'Common', '', '', '44', '', '', ''),
(144, 'Missile Cruiser', 145, 143, 2, 'Ship', 1, 'Cruiser', 'When you play this deal 4 damage to an enemy ship', '', '', 8, 6, '', 'Mars', 'Common', '', '', '45', '', '', ''),
(145, 'Missile Cruiser', 145, 144, 3, 'Ship', 1, 'Cruiser', 'When you play this deal 6 damage to an enemy ship', '', '', 12, 14, '', 'Mars', 'Common', '', '', '46', '', '', ''),
(146, 'Burn the Face', 147, 0, 1, 'Effect', 1, '', 'Deal randomly 1 to 10 damage to the enemy player', '', '', 0, 0, '', 'Mars', 'Common', '', '', '', '', '9', '49'),
(147, 'Burn the Face', 148, 146, 2, 'Effect', 1, '', 'Deal randomly 1 to 15 damage to the enemy player', '', '', 0, 0, '', 'Mars', 'Common', '', '', '', '', '9', '50'),
(148, 'Burn the Face', 148, 147, 3, 'Effect', 1, '', 'Deal randomly 1 to 20 damage to the enemy player', '', '', 0, 0, '', 'Mars', 'Common', '', '', '', '', '9', '51'),
(149, 'Caster Platform', 150, 0, 1, 'Ship', 1, 'Caster', '', '', '', 5, 6, '', 'Mars', 'Common', '', '', '', '', '', ''),
(150, 'Caster Platform', 151, 149, 2, 'Ship', 1, 'Caster', 'You may give a level 1 Effect in your hand \"Free\"', '', '', 9, 10, '', 'Mars', 'Common', '', '', '47', '', '', ''),
(151, 'Caster Platform', 151, 150, 3, 'Ship', 1, 'Caster', 'You may give a level 2 or lower Effect in your hand \"Free\"', '', '', 17, 16, '', 'Mars', 'Common', '', '', '48', '', '', ''),
(152, 'Nullify', 153, 0, 1, 'Effect', 1, '', 'Reduce a level 1 enemy ship\'s attack to 0', '', '', 0, 0, '', 'Earth', 'Common', '', '', '', '', '12', '53'),
(153, 'Nullify', 154, 152, 2, 'Effect', 1, '', 'Reduce an level 2 or less enemy ship\'s attack to 0', '', '', 0, 0, '', 'Earth', 'Common', '', '', '', '', '13', '53'),
(154, 'Nullify', 154, 153, 3, 'Effect', 1, '', 'Reduce an enemy ship\'s attack to 0', '', '', 0, 0, '', 'Earth', 'Common', '', '', '', '', '14', '53'),
(155, 'Misshapen Barge', 156, 0, 1, 'Ship', 1, 'Barge', '', '', '', 4, 4, '', 'Mars', 'Common', '', '', '', '', '', ''),
(156, 'Misshapen Barge', 157, 155, 2, 'Ship', 1, 'Barge', '', '', '', 8, 9, '', 'Mars', 'Common', '', '', '', '', '', ''),
(157, 'Misshapen Barge', 157, 156, 3, 'Ship', 1, 'Barge', '', '', '', 13, 14, '', 'Mars', 'Common', '', '', '', '', '', ''),
(158, 'Fair Trade', 159, 0, 1, 'Effect', 1, '', 'Destroy a free enemy ship', '', '', 0, 0, '', 'Mars', 'Common', '', '', '', '', '15', '54'),
(159, 'Fair Trade', 160, 158, 2, 'Effect', 1, '', 'Destroy a free enemy ship', '', '', 0, 0, '', 'Mars', 'Common', 'Free', '', '', '', '15', '54'),
(160, 'Fair Trade', 160, 159, 3, 'Effect', 1, '', 'Destroy up to two free enemy ships', '', '', 0, 0, '', 'Mars', 'Common', 'Free', '', '', '', '15, 15', '54, 55'),
(161, 'Probe', 162, 0, 1, 'Ship', 1, 'Probe', '', '', '', 3, 3, '', 'Earth', 'Common', '', '', '', '', '', ''),
(162, 'Probe', 163, 161, 2, 'Ship', 1, 'Probe', '', '', '', 5, 5, '', 'Earth', 'Common', 'Free', '', '', '', '', ''),
(163, 'Probe', 163, 162, 3, 'Ship', 1, 'Probe', '', '', '', 7, 7, '', 'Earth', 'Common', 'Free', '', '', '', '', ''),
(164, 'Small Wither', 165, 0, 1, 'Effect', 1, '', 'An enemy ship gets -2/-2', '', '', 0, 0, '', 'Dralk', 'Common', '', '', '', '', '5', '56'),
(165, 'Small Wither', 166, 164, 2, 'Effect', 1, '', 'An enemy ship gets -3/-3', '', '', 0, 0, '', 'Dralk', 'Common', 'Free', '', '', '', '5', '57'),
(166, 'Small Wither', 166, 165, 3, 'Effect', 1, '', 'An enemy ship gets -4/-4', '', '', 0, 0, '', 'Dralk', 'Common', 'Free', '', '', '', '5', '58'),
(167, 'Defensive Structure', 168, 0, 1, 'Ship', 1, 'Station', '', '', '', 9, 7, '', 'Mars', 'Common', 'Blocker', '', '', '', '', ''),
(168, 'Defensive Structure', 169, 167, 2, 'Ship', 1, 'Station', '', '', '', 16, 14, '', 'Mars', 'Common', 'Blocker', '', '', '', '', ''),
(169, 'Defensive Structure', 169, 168, 3, 'Ship', 1, 'Station', '', '', '', 20, 22, '', 'Mars', 'Common', 'Blocker', '', '', '', '', ''),
(170, 'Destruction Reveler', 171, 0, 1, 'Ship', 1, 'Reveler', 'When another ship is destroyed this gets +1/+1', '', '', 4, 3, '', 'Dralk', 'Common', '', '', '49', '', '', ''),
(171, 'Destruction Reveler', 172, 170, 2, 'Ship', 1, 'Reveler', 'When another ship is destroyed this gets +2/+2', '', '', 4, 7, '', 'Dralk', 'Common', '', '', '50', '', '', ''),
(172, 'Destruction Reveler', 172, 171, 3, 'Ship', 1, 'Reveler', 'When another ship is destroyed this gets +3/+3', '', '', 7, 9, '', 'Dralk', 'Common', '', '', '51', '', '', ''),
(173, 'Freedom Fighter', 174, 0, 1, 'Ship', 1, 'Freedom Fighter', 'Loyal - If you have four or more Helkinite cards in hand when you play this it gets +4/+4', '', '', 3, 3, '', 'Helkinite', 'Common', '', '', '52', '', '', ''),
(174, 'Freedom Fighter', 175, 173, 2, 'Ship', 1, 'Freedom Fighter', 'Loyal - If you have four or more Helkinite cards in hand when you play this it gets +4/+4', '', '', 8, 8, '', 'Helkinite', 'Common', '', '', '52', '', '', ''),
(175, 'Freedom Fighter', 175, 174, 3, 'Ship', 1, 'Freedom Fighter', 'Loyal - If you have four or more Helkinite cards in hand when you play this it gets +4/+4', '', '', 14, 14, '', 'Helkinite', 'Common', '', '', '52', '', '', ''),
(176, 'Martian Defense Force', 177, 0, 1, 'Ship', 1, 'Defense Force', 'Loyal - If you have 4 or more Mars cards in your hand when you play this deal 1-4 damage to target enemy ship', '', '', 3, 4, '', 'Mars', 'Common', '', '', '53', '', '', ''),
(177, 'Martian Defense Force', 178, 176, 2, 'Ship', 1, 'Defense Force', 'Loyal - If you have 4 or more Mars cards in your hand when you play this deal 2-8 damage to target enemy ship', '', '', 7, 6, '', 'Mars', 'Common', '', '', '54', '', '', ''),
(178, 'Martian Defense Force', 178, 177, 3, 'Ship', 1, 'Defense Force', 'Loyal - If you have 4 or more Mars cards in your hand when you play this deal 3-12 damage to target enemy ship', '', '', 12, 13, '', 'Mars', 'Common', '', '', '55', '', '', ''),
(179, 'Trade Caravan', 180, 0, 1, 'Ship', 1, 'Caravan', 'Loyal - If you have 4 or more Dralk cards in your hand when you play this, all ships you control gain \"Repair 2\"\r\n', '', '', 4, 5, '', 'Dralk', 'Common', '', '', '56', '', '', ''),
(180, 'Trade Caravan', 181, 179, 2, 'Ship', 1, 'Caravan', 'Loyal - If you have 4 or more Dralk cards in your hand when you play this, all ships you control gain \"Repair 4\"\r\n', '', '', 8, 10, '', 'Dralk', 'Common', '', '', '57', '', '', ''),
(181, 'Trade Caravan', 181, 180, 3, 'Ship', 1, 'Caravan', 'Loyal - If you have 4 or more Dralk cards in your hand when you play this, all ships you control gain \"Repair 6\"\r\n', '', '', 14, 15, '', 'Dralk', 'Common', '', '', '58', '', '', ''),
(182, 'Earth Research Station', 183, 0, 1, 'Ship', 1, 'Station', '', '', '', 5, 5, '', 'Earth', 'Common', 'Blocker', '', '', '', '', ''),
(183, 'Earth Research Station', 184, 182, 2, 'Ship', 1, 'Station', 'Loyal - If you have 4 or more Earth cards in hand when you play this level a level 1 card in your hand', '', '', 10, 10, '', 'Earth', 'Common', 'Blocker', '', '59', '', '', ''),
(184, 'Earth Research Station', 184, 183, 3, 'Ship', 1, 'Station', 'Loyal - If you have 4 or more Earth cards in hand when you play this level a level 2 or lower card in your hand', '', '', 15, 15, '', 'Earth', 'Common', 'Blocker', '', '59', '', '', ''),
(185, 'Center Support', 186, 0, 1, 'Ship', 1, '', 'When you play a ship to the center lane give it +2/+2', '', '', 4, 6, '', 'Earth', 'Common', '', '', '60', '', '', ''),
(186, 'Center Support', 187, 185, 2, 'Ship', 1, '', 'When you play a ship to the center lane give it +4/+4', '', '', 8, 12, '', 'Earth', 'Common', '', '', '61', '', '', ''),
(187, 'Center Support', 187, 186, 3, 'Ship', 1, '', 'When you play a ship to the center lane give it +6/+6', '', '', 12, 14, '', 'Earth', 'Common', '', '', '62', '', '', ''),
(188, 'Flanking Master', 189, 0, 1, 'Ship', 1, 'Corvette', 'When a ship is played in a edge lane give it +2/+2 and repair 1', '', '', 5, 3, '', 'Dralk', 'Common', '', '', '63,64,65,66', '', '', ''),
(189, 'Flanking Master', 190, 188, 2, 'Ship', 1, 'Corvette', 'When a ship is played in a edge lane give it +3/+3 and repair 2', '', '', 9, 7, '', 'Dralk', 'Common', '', '', '79,80,81,82', '', '', ''),
(190, 'Flanking Master', 190, 189, 3, 'Ship', 1, 'Corvette', 'When a ship is played in a edge lane give it +4/+4 and repair 3', '', '', 12, 9, '', 'Dralk', 'Common', '', '', '83,84,85,86', '', '', ''),
(191, 'Racing Craft', 192, 0, 1, 'Ship', 1, 'racer', '', '', '', 4, 2, '', 'Mars', 'Common', 'Fast', '', '', '', '', ''),
(192, 'Racing Craft', 193, 191, 2, 'Ship', 1, 'racer', '', '', '', 7, 4, '', 'Mars', 'Common', 'Fast', '', '', '', '', ''),
(193, 'Racing Craft', 193, 192, 3, 'Ship', 1, 'racer', '', '', '', 11, 10, '', 'Mars', 'Common', 'Fast', '', '', '', '', ''),
(194, 'Twin Frigates', 195, 0, 1, 'Ship', 1, 'Frigate', 'When this is play summon a copy of it in a random empty lane.', '', '', 5, 3, '', 'Helkinite', 'Common', '', '', '67', '', '', ''),
(195, 'Twin Frigates', 196, 194, 2, 'Ship', 1, 'Frigate', 'When this is play summon a copy of it in a random empty lane.', '', '', 10, 7, '', 'Helkinite', 'Common', '', '', '68', '', '', ''),
(196, 'Twin Frigates', 196, 195, 3, 'Ship', 1, 'Frigate', 'When this is play summon a copy of it in a random empty lane.', '', '', 14, 10, '', 'Helkinite', 'Common', '', '', '69', '', '', ''),
(197, 'Ramscoop Module', 198, 0, 1, 'Effect', 1, '', 'Give a friendly ship \"Drain\"', '', '', 0, 0, '', 'Dralk', 'Common', '', '', '', '', '1', '60'),
(198, 'Ramscoop Module', 199, 197, 2, 'Effect', 1, '', 'Give all friendly ships \"Drain\"', '', '', 0, 0, '', 'Dralk', 'Common', '', '', '', '', '7', '60'),
(199, 'Ramscoop Module', 199, 198, 3, 'Effect', 1, '', 'Give all friendly ships \"Drain\"', '', '', 0, 0, '', 'Dralk', 'Common', 'Free', '', '', '', '7', '60'),
(200, 'Overwhelm Protocol', 201, 0, 1, 'Effect', 1, '', 'Give a ship you control \"Relentless\"', '', '', 0, 0, '', 'Helkinite', 'Common', '', '', '', '', '1', '61'),
(201, 'Overwhelm Protocol', 202, 200, 2, 'Effect', 1, '', 'Give all ships you control \"Relentless\"', '', '', 0, 0, '', 'Helkinite', 'Common', '', '', '', '', '7', '61'),
(202, 'Overwhelm Protocol', 202, 201, 3, 'Effect', 1, '', 'Give all ships you control \"Relentless\"', '', '', 0, 0, '', 'Helkinite', 'Common', 'Free', '', '', '', '7', '61'),
(203, 'Speed Mandate', 204, 0, 1, 'Effect', 1, '', 'Give a friendly ship \"Fast\"', '', '', 0, 0, '', 'Mars', 'Common', '', '', '', '', '1', '62'),
(204, 'Speed Mandate', 205, 203, 2, 'Effect', 1, '', 'Give all friendly ships \"Fast\"', '', '', 0, 0, '', 'Mars', 'Common', '', '', '', '', '7', '62'),
(205, 'Speed Mandate', 205, 204, 3, 'Effect', 1, '', 'Give all friendly ships \"Fast\"', '', '', 0, 0, '', 'Mars', 'Common', 'Free', '', '', '', '7', '62'),
(206, 'Blockade Ship', 207, 0, 1, 'Ship', 1, '', 'When you play this look at your opponent\'s hand and make them discard a level 1 card.', '', '', 4, 5, '', 'Dralk', 'Common', '', '', '70', '', '', ''),
(207, 'Blockade Ship', 208, 206, 2, 'Ship', 1, '', 'When you play this look at your opponent\'s hand and make them discard a level 2 or less card.', '', '', 9, 10, '', 'Dralk', 'Common', '', '', '73', '', '', ''),
(208, 'Blockade Ship', 208, 207, 3, 'Ship', 1, '', 'When you play this look at your opponent\'s hand and make them discard a card.', '', '', 14, 15, '', 'Dralk', 'Common', '', '', '74', '', '', ''),
(210, 'Prepared Constructor', 211, 0, 1, 'Ship', 1, '', 'Give a level 1 ship in your deck \"Fast\"', '', '', 5, 4, '', 'Mars', 'Common', '', '', '75', '', '', ''),
(211, 'Prepared Constructor', 212, 210, 2, 'Ship', 1, '', 'Give a level 2 or lower ship in your deck \"Fast\"', '', '', 8, 7, '', 'Mars', 'Common', '', '', '76', '', '', ''),
(212, 'Prepared Constructor', 212, 211, 3, 'Ship', 1, '', 'Give a ship in your deck \"Fast\"', '', '', 13, 12, '', 'Mars', 'Common', '', '', '77', '', '', ''),
(213, 'Wreckage Flinger', 214, 0, 1, 'Ship', 1, '', 'Activate: Sacrifice a ship you control, destroy a level 1 ship your opponent controls', '', '', 2, 7, '', 'Dralk', 'Common', '', '', '', '1', '', ''),
(214, 'Wreckage Flinger', 215, 213, 2, 'Ship', 1, '', 'Activate: Sacrifice a ship you control, destroy a level 2 or lower ship your opponent controls', '', '', 4, 14, '', 'Dralk', 'Common', '', '', '', '2', '', ''),
(215, 'Wreckage Flinger', 215, 214, 3, 'Ship', 1, '', 'Activate: Sacrifice a ship you control, destroy a ship your opponent controls', '', '', 6, 18, '', 'Dralk', 'Common', '', '', '', '3', '', ''),
(216, 'Repair Bot', 217, 0, 1, 'Ship', 1, 'Robot', 'Activate: Give a friendly ship repair 2', '', '', 4, 6, '', 'Earth', 'Common', '', '', '', '4', '', ''),
(217, 'Repair Bot', 218, 216, 2, 'Ship', 1, 'Robot', 'Activate: Give a friendly ship repair 3', '', '', 8, 11, '', 'Earth', 'Common', '', '', '', '5', '', ''),
(218, 'Repair Bot', 218, 217, 3, 'Ship', 1, 'Robot', 'Activate: Give a friendly ship repair 4', '', '', 13, 17, '', 'Earth', 'Common', '', '', '', '6', '', ''),
(219, 'Production Bot', 220, 0, 1, 'Ship', 1, 'Robot', 'Activate: Draw a level 1 card of your choice', '', '', 2, 6, '', 'Earth', 'Common', '', '', '', '7', '', ''),
(220, 'Production Bot', 221, 119, 2, 'Ship', 1, 'Robot', 'Activate: Draw a level 2 or less card of your choice', '', '', 4, 10, '', 'Earth', 'Common', '', '', '', '8', '', ''),
(221, 'Production Bot', 221, 120, 3, 'Ship', 1, 'Robot', 'Activate: Draw a level 3 or less card of your choice', '', '', 8, 14, '', 'Earth', 'Common', '', '', '', '9', '', ''),
(222, 'Cleanse', 223, 0, 1, 'Effect', 1, '', 'Negate all keywords and remove all abilities from a level 1 enemy ship. Reset it\'s attack and max health to it\'s printed value.', '', '', 0, 0, '', 'Earth', 'Common', '', '', '', '', '12', '68'),
(223, 'Cleanse', 224, 22, 2, 'Effect', 1, '', 'Negate all keywords and remove all abilities from a level 2 or lower enemy ship. Reset it\'s attack and max health to it\'s printed value.', '', '', 0, 0, '', 'Earth', 'Common', '', '', '', '', '13', '68'),
(224, 'Cleanse', 224, 223, 3, 'Effect', 1, '', 'Negate all keywords and remove all abilities from an enemy ship. Reset it\'s attack and max health to it\'s printed value.', '', '', 0, 0, '', 'Earth', 'Common', '', '', '', '', '5', '68'),
(225, 'Restriction Breaker', 226, 0, 1, 'Ship', 1, '', 'When you play this a ship loses and can\'t gain \"Blocker\"', '', '', 6, 2, '', 'Mars', 'Common', '', '', '78', '', '', ''),
(226, 'Restriction Breaker', 227, 225, 2, 'Ship', 1, '', 'When you play this a ship loses and can\'t gain \"Blocker\"', '', '', 12, 6, '', 'Mars', 'Common', '', '', '78', '', '', ''),
(227, 'Restriction Breaker', 227, 226, 3, 'Ship', 1, '', 'When you play this a ship loses and can\'t gain \"Blocker\"', '', '', 18, 13, '', 'Mars', 'Common', '', '', '78', '', '', ''),
(228, 'Defense Duty', 229, 0, 1, 'Effect', 1, '', 'Give a level 2 or lower ship \"Blocker\"', '', '', 0, 0, '', 'Mars', 'Common', '', '', '', '', '27', '70'),
(229, 'Defense Duty', 230, 228, 2, 'Effect', 1, '', 'Give a ship \"Blocker\"', '', '', 0, 0, '', 'Mars', 'Common', '', '', '', '', '26', '70'),
(230, 'Defense Duty', 230, 229, 3, 'Effect', 1, '', 'Give a ship \"Blocker\"', '', '', 0, 0, '', 'Mars', 'Common', 'Free', '', '', '', '26', '70'),
(231, 'Longbow Bomber', 232, 0, 1, 'Ship', 1, 'Bomber', 'When this has 5 or more attack it has \"Relentless\"', '', '', 4, 6, '', 'Earth', 'Common', '', '1', '', '', '', ''),
(232, 'Longbow Bomber', 233, 231, 2, 'Ship', 1, 'Bomber', 'When this has 10 or more attack it has \"Relentless\"', '', '', 9, 12, '', 'Earth', 'Common', '', '2', '', '', '', ''),
(233, 'Longbow Bomber', 233, 232, 3, 'Ship', 1, 'Bomber', 'When this has 15 or more attack it has \"Relentless\"', '', '', 14, 16, '', 'Earth', 'Common', '', '3', '', '', '', ''),
(234, 'Archeological ship', 235, 0, 1, 'Ship', 1, 'Archeological', 'When this is played return a level 1 ship from your discard to your hand', '', '', 5, 5, '', 'Helkinite', 'Common', '', '', '87', '', '', ''),
(235, 'Archeological ship', 236, 234, 2, 'Ship', 1, 'Archeological', 'When this is played return a level 2 or lower ship from your discard to your hand', '', '', 10, 10, '', 'Helkinite', 'Common', '', '', '88', '', '', ''),
(236, 'Archeological ship', 236, 235, 3, 'Ship', 1, 'Archeological', 'When this is played return a level 3 or lower ship from your discard to your hand', '', '', 15, 15, '', 'Helkinite', 'Common', '', '', '89', '', '', ''),
(237, 'Thief of Thought', 238, 0, 1, 'Ship', 1, 'Thief', 'When this is played steal a level 1 card from your opponent\'s hand.', '', '', 5, 5, '', 'Mars', 'Common', '', '', '90', '', '', ''),
(238, 'Thief of Thought', 238, 236, 2, 'Ship', 1, 'Thief', 'When this is played steal a level 2 card from your opponent\'s hand.', '', '', 10, 10, '', 'Mars', 'Common', '', '', '91', '', '', ''),
(239, 'Thief of Thought', 238, 237, 3, 'Ship', 1, 'Thief', 'When this is played steal a level 3 or lower card from your opponent\'s hand.', '', '', 15, 15, '', 'Mars', 'Common', '', '', '92', '', '', ''),
(240, 'Repair Wave', 241, 0, 1, 'Effect', 1, '', 'Heal 3 damage from all ships and gain 3 life.', '', '', 0, 0, '', 'Helkinite', 'Common', '', '', '', '', '37', '74,75'),
(241, 'Repair Wave', 242, 240, 2, 'Effect', 1, '', 'Heal 6 damage from all ships and gain 6 life.', '', '', 0, 0, '', 'Helkinite', 'Common', '', '', '', '', '37', '76,77'),
(242, 'Repair Wave', 242, 241, 3, 'Effect', 1, '', 'Heal 9 damage from all ships and gain 9 life.', '', '', 0, 0, '', 'Helkinite', 'Common', '', '', '', '', '37', '78,79'),
(243, 'Vault Blockade', 244, 0, 1, 'Ship', 1, 'Blockade', '', '', '', 0, 15, '', 'Earth', 'Common', '', '', '', '', '', ''),
(244, 'Vault Blockade', 245, 243, 2, 'Ship', 1, 'Blockade', '', '', '', 0, 30, '', 'Earth', 'Common', '', '', '', '', '', ''),
(245, 'Vault Blockade', 245, 244, 3, 'Ship', 1, 'Blockade', '', '', '', 0, 45, '', 'Earth', 'Common', '', '', '', '', '', ''),
(246, 'Ramming Speed', 247, 0, 1, 'Effect', 1, '', 'Sacrifice a ship to destroy a level 2 or lower ship', '', '', 0, 0, '', 'Dralk', 'Common', '', '', '', '', '27,37', '54,55'),
(247, 'Ramming Speed', 248, 246, 2, 'Effect', 1, '', 'Sacrifice a ship to destroy a ship', '', '', 0, 0, '', 'Dralk', 'Common', '', '', '', '', '26,37', '54,55'),
(248, 'Ramming Speed', 248, 247, 3, 'Effect', 1, '', 'Destroy a ship', '', '', 0, 0, '', 'Dralk', 'Common', '', '', '', '', '26', '54'),
(249, 'Rusted Monstrosity', 250, 0, 1, 'Ship', 1, '', '', '', '', 8, 7, '', 'Dralk', 'Common', 'Decay 1', '', '', '', '', ''),
(250, 'Rusted Monstrosity', 251, 249, 2, 'Ship', 1, '', '', '', '', 13, 11, '', 'Dralk', 'Common', 'Decay 2', '', '', '', '', ''),
(251, 'Rusted Monstrosity', 251, 250, 3, 'Ship', 1, '', '', '', '', 19, 17, '', 'Dralk', 'Common', 'Decay 3', '', '', '', '', ''),
(252, 'Rusted Jalopy', 253, 0, 1, 'Ship', 1, '', 'When a ship is played opposite of this, this gains \"Decay 2\"', '', '', 9, 10, '', 'Dralk', 'Common', '', '', '93', '', '', ''),
(253, 'Rusted Jalopy', 254, 252, 2, 'Ship', 1, '', 'When a ship is played opposite of this, this gains \"Decay 4\"', '', '', 15, 17, '', 'Dralk', 'Common', '', '', '94', '', '', ''),
(254, 'Rusted Jalopy', 254, 253, 3, 'Ship', 1, '', 'When a ship is played opposite of this, this gains \"Decay 6\"', '', '', 22, 23, '', 'Dralk', 'Common', '', '', '95', '', '', ''),
(255, 'Spitter', 256, 0, 1, 'Ship', 1, 'Snake', 'Activate: Target enemy ship gains \"Decay 2\"', '', '', 4, 5, '', 'Helkinite', 'Common', '', '', '', '10', '', ''),
(256, 'Spitter', 257, 255, 2, 'Ship', 1, 'Snake', 'Activate: Target enemy ship gains \"Decay 4\"', '', '', 9, 10, '', 'Helkinite', 'Common', '', '', '', '11', '', ''),
(257, 'Spitter', 257, 256, 3, 'Ship', 1, 'Snake', 'Activate: Target enemy ship gains \"Decay 6\"', '', '', 14, 15, '', 'Helkinite', 'Common', '', '', '', '12', '', ''),
(258, 'Recycletron 2000', 259, 0, 1, 'Ship', 1, 'Recycletron', 'When a ship is destroyed you gain 2 life', '', '', 3, 4, '', 'Helkinite', 'Common', '', '', '96', '', '', ''),
(259, 'Recycletron 2000', 260, 258, 2, 'Ship', 1, 'Recycletron', 'When a ship is destroyed you gain 4 life', '', '', 7, 9, '', 'Helkinite', 'Common', '', '', '97', '', '', ''),
(260, 'Recycletron 2000', 260, 259, 3, 'Ship', 1, 'Recycletron', 'When a ship is destroyed you gain 8 life', '', '', 14, 14, '', 'Helkinite', 'Common', '', '', '98', '', '', ''),
(261, 'Bound Thought', 261, 0, 1, 'Ship', 1, '', 'When you play this if your level is 2 or higher draw 2 cards', '', '', 6, 3, '', 'Earth', 'Common', '', '', '99', '', '', ''),
(262, 'Bound Thought', 263, 261, 2, 'Ship', 1, '', 'When you play this if your level is 2 or higher draw 4 cards', '', '', 12, 6, '', 'Earth', 'Common', '', '', '100', '', '', ''),
(263, 'Bound Thought', 263, 262, 3, 'Ship', 1, '', 'When you play this if your level is 2 or higher draw 6 cards', '', '', 18, 12, '', 'Earth', 'Common', '', '', '101', '', '', ''),
(264, 'Last Minute Research', 265, 0, 1, 'Effect', 1, '', 'Target enemy ship gets -3/-0 and discard and level a card in your hand', '', '', 0, 0, '', 'Earth', 'Common', '', '', '', '', '5,3', '86,87'),
(265, 'Last Minute Research', 266, 264, 2, 'Effect', 1, '', 'Target enemy ship gets -6/-0 and discard and level a card in your hand', '', '', 0, 0, '', 'Earth', 'Common', '', '', '', '', '5,3', '88,89'),
(266, 'Last Minute Research', 266, 265, 3, 'Effect', 1, '', 'Target enemy ship gets -9/-0 and discard and level a card in your hand', '', '', 0, 0, '', 'Earth', 'Common', '', '', '', '', '5,3', '90,91'),
(267, 'Engine Binder', 268, 0, 1, 'Ship', 1, '', 'Activate: Target ship gains Blocker', '', '', 1, 5, '', 'Mars', 'Common', '', '', '', '13', '', ''),
(268, 'Engine Binder', 269, 267, 2, 'Ship', 1, '', 'Activate: Target ship gains Blocker', '', '', 2, 10, '', 'Mars', 'Common', '', '', '', '13', '', ''),
(269, 'Engine Binder', 269, 268, 3, 'Ship', 1, '', 'Activate: Target ship gains Blocker', '', '', 5, 15, '', 'Mars', 'Common', '', '', '', '13', '', ''),
(270, 'Bound Endurance', 271, 0, 1, 'Ship', 1, '', 'When you play this if you are level 2 or higher give a ship +5 hull', '', '', 7, 2, '', 'Mars', 'Common', '', '', '103', '', '', ''),
(271, 'Bound Endurance', 272, 270, 2, 'Ship', 1, '', 'When you play this if you are level 2 or higher give a ship +10 hull', '', '', 14, 4, '', 'Mars', 'Common', '', '', '104', '', '', ''),
(272, 'Bound Endurance', 272, 271, 3, 'Ship', 1, '', 'When you play this if you are level 2 or higher give a ship +15 hull', '', '', 16, 16, '', 'Mars', 'Common', '', '', '105', '', '', ''),
(273, 'Bound Decay', 274, 0, 1, 'Ship', 1, '', 'When you play this if your level is 2 or higher target ship gains \"Decay 3\"', '', '', 5, 4, '', 'Helkinite', 'Common', '', '', '106', '', '', ''),
(274, 'Bound Decay', 275, 273, 2, 'Ship', 1, '', 'When you play this if your level is 3 or higher target ship gains \"Decay 6\"', '', '', 10, 9, '', 'Helkinite', 'Common', '', '', '107', '', '', ''),
(275, 'Bound Decay', 275, 274, 3, 'Ship', 1, '', 'When you play this if your level is 4 or higher target ship gains \"Decay 9\"', '', '', 15, 14, '', 'Helkinite', 'Common', '', '', '108', '', '', ''),
(276, 'Bound Loss', 277, 0, 1, 'Ship', 1, '', 'When you play this if your level is 2 or more give an enemy ship -3/-3', '', '', 8, 2, '', 'Dralk', 'Common', '', '', '109', '', '', ''),
(277, 'Bound Loss', 278, 276, 2, 'Ship', 1, '', 'When you play this if your level is 3 or more give an enemy ship -6/-6', '', '', 13, 8, '', 'Dralk', 'Common', '', '', '110', '', '', ''),
(278, 'Bound Loss', 278, 277, 3, 'Ship', 1, '', 'When you play this if your level is 4 or more give an enemy ship -9/-9', '', '', 18, 12, '', 'Dralk', 'Common', '', '', '111', '', '', ''),
(279, 'Drone', 0, 0, 1, 'Ship', 1, '', '', '', '', 2, 2, '', 'Dralk', 'Token', '', '', '', '', '', ''),
(280, 'Drone', 0, 0, 2, 'Ship', 1, '', '', '', '', 4, 4, '', 'Dralk', 'Token', '', '', '', '', '', ''),
(281, 'Drone', 0, 0, 3, 'Ship', 1, '', '', '', '', 6, 6, '', 'Dralk', 'Token', '', '', '', '', '', ''),
(282, 'Ship Flinger', 283, 0, 1, 'Ship', 1, 'Doomwake', 'When you play this create a drone in a random lane.\r\nActivate: Destroy a friendly ship and a level 1 enemy ship.\r\n', '', '', 3, 7, '', 'Dralk', 'Common', '', '', '112', '1', '', ''),
(283, 'Ship Flinger', 284, 282, 2, 'Ship', 1, 'Doomwake', 'When you play this create a drone in a random lane.\r\nActivate: Destroy a friendly ship and a level 2 or lower enemy ship.\r\n', '', '', 6, 14, '', 'Dralk', 'Common', '', '', '113', '2', '', ''),
(284, 'Ship Flinger', 284, 283, 3, 'Ship', 1, 'Doomwake', 'When you play this create a drone in a random lane.\r\nActivate: Destroy a friendly ship and an enemy ship.\r\n', '', '', 9, 18, '', 'Dralk', 'Common', '', '', '114', '3', '', '');

-- --------------------------------------------------------

--
-- Table structure for table `effects`
--

CREATE TABLE `effects` (
  `effectid` int(11) NOT NULL,
  `effecttype` varchar(255) NOT NULL,
  `effecttarget` varchar(255) NOT NULL,
  `effectmod1` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `effects`
--

INSERT INTO `effects` (`effectid`, `effecttype`, `effecttarget`, `effectmod1`) VALUES
(1, 'stats', 'self', '+3/+3'),
(2, 'stats', 'self', '+6/+6'),
(3, 'stats', 'self', '+12/+12'),
(4, 'stats', 'target0', '+0/+2'),
(5, 'stats', 'target0', '+0/+4'),
(6, 'stats', 'target0', '+0/+6'),
(7, 'stats', 'target0', '+3/+0'),
(8, 'stats', 'target0', '+6/+0'),
(9, 'stats', 'target0', '+9/+0'),
(10, 'draw', 'controller', '1'),
(11, 'stats', 'target0', '+1/+1'),
(12, 'stats', 'target0', '+3/+3'),
(13, 'stats', 'target0', '+5/+5'),
(14, 'level', 'target0', '1'),
(15, 'stats', 'target0', '-2/-2'),
(16, 'stats', 'target0', '-4/-4'),
(17, 'stats', 'target0', '-6/-6'),
(18, 'stats', 'target0', '-3/-3'),
(19, 'stats', 'target0', '-5/-5'),
(20, 'stats', 'target0', '-7/-7'),
(21, 'keyword', 'self', 'Free'),
(22, 'Damage', 'target0', '5'),
(23, 'Damage', 'opponent', '5'),
(24, 'Damage', 'target0', '10'),
(25, 'Damage', 'opponent', '10'),
(26, 'Damage', 'target0', '15'),
(27, 'Damage', 'opponent', '15'),
(28, 'stats', 'target0', '+3/+0'),
(29, 'stats', 'target1', '-3/-0'),
(30, 'stats', 'target0', '+6/+0'),
(31, 'stats', 'target1', '-6/-0'),
(32, 'stats', 'target0', '+8/+0'),
(33, 'stats', 'target1', '-8/-0'),
(34, 'stats', 'target0', '+3/+3'),
(35, 'stats', 'target0', '+5/+5'),
(36, 'stats', 'target0', '+7/+7'),
(37, 'keyword', 'target0', 'Relentless'),
(38, 'keyword', 'target0', 'Relentless'),
(39, 'stats', 'target0', '+6/+6'),
(40, 'Damage', 'target0', '8'),
(41, 'Damage', 'target1', '8'),
(42, 'stats', 'target0', '-4/-4'),
(43, 'stats', 'target1', '-4/-4'),
(44, 'level', 'target0', '1'),
(45, 'level', 'target1', '1'),
(46, 'Damage', 'target0', '2'),
(47, 'Damage', 'target0', '4'),
(48, 'Damage', 'target0', '6'),
(49, 'Damage', 'opponent', '1-10'),
(50, 'Damage', 'opponent', '1-15'),
(51, 'Damage', 'opponent', '1-20'),
(52, 'keyword', 'self', 'Free'),
(53, 'stats', 'target0', '=0/+0'),
(54, 'Destroy', 'target0', ''),
(55, 'Destroy', 'target1', ''),
(56, 'stats', 'target0', '-2/-2'),
(57, 'stats', 'target0', '-3/-3'),
(58, 'stats', 'target0', '-4/-4'),
(59, 'levelinhand', 'target0', '1'),
(60, 'keyword', 'self', 'Drain'),
(61, 'keyword', 'self', 'Relentless'),
(62, 'keyword', 'self', 'Fast'),
(63, 'Discard', 'target0', ''),
(64, 'keyword', 'self', 'Repair 2'),
(65, 'keyword', 'self', 'Repair 3'),
(66, 'keyword', 'self', 'Repair 4'),
(67, 'drawspecific', 'target0', ''),
(68, 'Silence', 'target0', ''),
(69, 'Negate', 'target0', 'Blocker'),
(70, 'keyword', 'target0', 'Blocker'),
(71, 'keyword', 'target0', 'Relentless 1'),
(72, 'drawspecific', 'target0', ''),
(73, 'drawspecific', 'target0', ''),
(74, 'heal', 'controller', '3'),
(75, 'heal', 'target0', '3'),
(76, 'heal', 'controller', '6'),
(77, 'heal', 'target0', '6'),
(78, 'heal', 'controller', '9'),
(79, 'heal', 'target0', '9'),
(80, 'keyword', 'target0', 'Decay 2'),
(81, 'keyword', 'target0', 'Decay 4'),
(82, 'keyword', 'target0', 'Decay 6'),
(83, 'heal', 'controller', '2'),
(84, 'heal', 'controller', '4'),
(85, 'heal', 'controller', '8'),
(86, 'stats', 'target0', '-3/-0'),
(87, 'level', 'target1', '1'),
(88, 'stats', 'target0', '-6/-0'),
(89, 'level', 'target1', '1'),
(90, 'stats', 'target0', '-9/-0'),
(91, 'level', 'target1', '1'),
(92, 'keyword', 'target0', 'Blocker 1'),
(93, 'stats', 'target0', '+0/+5'),
(94, 'stats', 'target0', '+0/+10'),
(95, 'stats', 'target0', '+0/+15'),
(96, 'keyword', 'target0', 'Decay 3'),
(97, 'keyword', 'target0', 'Decay 6'),
(98, 'keyword', 'target0', 'Decay 9'),
(99, 'stats', 'target0', '-3/-3'),
(100, 'stats', 'target0', '-6/-6'),
(101, 'stats', 'target0', '-9/-9');

-- --------------------------------------------------------

--
-- Table structure for table `static`
--

CREATE TABLE `static` (
  `id` int(11) NOT NULL,
  `conditional` int(11) NOT NULL,
  `effect` int(11) NOT NULL,
  `target` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `static`
--

INSERT INTO `static` (`id`, `conditional`, `effect`, `target`) VALUES
(1, 28, 71, 'self'),
(2, 29, 71, 'self'),
(3, 30, 71, 'self');

-- --------------------------------------------------------

--
-- Table structure for table `targets`
--

CREATE TABLE `targets` (
  `targetid` int(11) NOT NULL,
  `text` varchar(255) NOT NULL,
  `targettype` varchar(255) NOT NULL,
  `maxtargets` int(11) NOT NULL,
  `mintargets` int(11) NOT NULL,
  `target1var` varchar(255) NOT NULL,
  `target1compare` varchar(3) NOT NULL,
  `target1target` varchar(255) NOT NULL,
  `target2var` varchar(255) NOT NULL,
  `target2compare` varchar(3) NOT NULL,
  `target2target` varchar(255) NOT NULL,
  `target3var` varchar(255) NOT NULL,
  `target3compare` varchar(5) NOT NULL,
  `target3target` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `targets`
--

INSERT INTO `targets` (`targetid`, `text`, `targettype`, `maxtargets`, `mintargets`, `target1var`, `target1compare`, `target1target`, `target2var`, `target2compare`, `target2target`, `target3var`, `target3compare`, `target3target`) VALUES
(1, 'Choose Target Ship', 'Ship', 1, 1, 'self.owner', '=', 'core.turn', '', '', '', '', '', ''),
(2, 'No target', 'controller', 0, 0, '', '', '', '', '', '', '', '', ''),
(3, 'Choose a Card in Hand', 'cardinhand', 1, 1, '', '', '', '', '', '', '', '', ''),
(4, '', 'allships', 0, 0, 'core.turn', '!=', 'self.owner', '', '', '', '', '', ''),
(5, 'Choose Target Enemy Ship', 'Ship', 1, 1, 'self.owner', '!=', 'core.turn', '', '', '', '', '', ''),
(6, 'Choose a Card in Hand', 'cardinhand', 1, 1, 'self.level', '<=', 'value.1', 'self.CardType', 'eq', 'value.Ship', '', '', ''),
(7, '', 'allships', 0, 0, 'core.turn', '=', 'self.owner', '', '', '', '', '', ''),
(8, 'Choose a Card in Hand', 'cardinhand', 1, 1, 'self.level', '<=', 'value.2', 'self.CardType', 'eq', 'value.Ship', '', '', ''),
(9, 'No target', 'controller', 0, 0, '', '', '', '', '', '', '', '', ''),
(10, 'Choose a Card in Hand', 'cardinhand', 1, 1, 'self.level', '<=', 'value.1', 'self.CardType', 'eq', 'value.Effect', '', '', ''),
(11, 'Choose a Card in Hand', 'cardinhand', 1, 1, 'self.level', '<=', 'value.2', 'self.CardType', 'eq', 'value.Effect', '', '', ''),
(12, 'Choose Target Enemy Ship', 'Ship', 1, 1, 'self.owner', '!=', 'core.turn', 'self.level', '<=', 'value.1', '', '', ''),
(13, 'Choose Target Enemy Ship', 'Ship', 1, 1, 'self.owner', '!=', 'core.turn', 'self.level', '<=', 'value.2', '', '', ''),
(14, 'Choose Target Enemy Ship', 'Ship', 1, 1, 'self.owner', '!=', 'core.turn', 'self.level', '<=', 'value.3', '', '', ''),
(15, 'Choose Target Enemy Ship', 'Ship', 1, 1, 'self.owner', '!=', 'core.turn', 'self.keyword.Free', '>=', 'value.1', '', '', ''),
(16, 'Choose a Card in Hand', 'cardinhand', 1, 1, 'self.level', '<=', 'value.1', 'self.Faction', 'eq', 'value.Earth', '', '', ''),
(17, 'Choose a card in your opponent\'s hand', 'allcards', 0, 0, 'self.owner', '!=', 'core.turn', 'self.zone', 'eq', 'value.hand', 'self.level', '<=', 'value.1'),
(18, 'Choose a card in your opponent\'s hand', 'allcards', 0, 0, 'self.owner', '!=', 'core.turn', 'self.zone', 'eq', 'value.hand', 'self.level', '<=', 'value.2'),
(19, 'Choose a card in your opponent\'s hand', 'allcards', 0, 0, 'self.owner', '!=', 'core.turn', 'self.zone', 'eq', 'value.hand', 'self.level', '<=', 'value.3'),
(20, 'Choose a card in your deck', 'allcards', 0, 0, 'self.owner', '=', 'core.turn', 'self.zone', 'eq', 'value.deck', 'self.level', '<=', 'value.1'),
(21, 'Choose a card in your deck', 'allcards', 0, 0, 'self.owner', '=', 'core.turn', 'self.zone', 'eq', 'value.deck', 'self.level', '<=', 'value.2'),
(22, 'Choose a card in your deck', 'allcards', 0, 0, 'self.owner', '=', 'core.turn', 'self.zone', 'eq', 'value.deck', 'self.level', '<=', 'value.3'),
(23, 'Choose Target Ship', 'Ship', 1, 1, 'self.owner', '=', 'core.turn', 'self.level', '=', 'value.1', '', '', ''),
(24, 'Choose Target Ship', 'Ship', 1, 1, 'self.owner', '=', 'core.turn', 'self.level', '<=', 'value.2', '', '', ''),
(25, 'Choose Target Ship', 'Ship', 1, 1, 'self.owner', '=', 'core.turn', 'self.level', '<=', 'value.3', '', '', ''),
(26, 'Choose any ship', 'Ship', 0, 0, '', '', '', '', '', '', '', '', ''),
(27, 'Choose any ship', 'Ship', 0, 0, 'self.level', '<=', 'value.2', '', '', '', '', '', ''),
(28, 'static check for power', 'self', 0, 0, 'self.Attack', '>=', 'value.5', '', '', '', '', '', ''),
(29, 'static check for power', 'self', 0, 0, 'self.Attack', '>=', 'value.10', '', '', '', '', '', ''),
(30, 'static check for power', 'self', 0, 0, 'self.Attack', '>=', 'value.15', '', '', '', '', '', ''),
(31, 'Choose a card in your discard', 'allcards', 0, 0, 'self.owner', '=', 'core.turn', 'self.zone', 'eq', 'value.discard', 'self.level', '<=', 'value.1'),
(32, 'Choose a card in your discard', 'allcards', 0, 0, 'self.owner', '=', 'core.turn', 'self.zone', 'eq', 'value.discard', 'self.level', '<=', 'value.2'),
(33, 'Choose a card in your discard', 'allcards', 0, 0, 'self.owner', '=', 'core.turn', 'self.zone', 'eq', 'value.discard', 'self.level', '<=', 'value.3'),
(34, 'Choose a card in your opponent\'s hand', 'allcards', 0, 0, 'self.owner', '!=', 'core.turn', 'self.zone', 'eq', 'value.hand', 'self.level', '<=', 'value.1'),
(35, 'Choose a card in your opponent\'s hand', 'allcards', 0, 0, 'self.owner', '!=', 'core.turn', 'self.zone', 'eq', 'value.hand', 'self.level', '<=', 'value.2'),
(36, 'Choose a card in your opponent\'s hand', 'allcards', 0, 0, 'self.owner', '!=', 'core.turn', 'self.zone', 'eq', 'value.hand', 'self.level', '<=', 'value.3'),
(37, '', 'Ship', 0, 0, 'core.turn', '=', 'self.owner', '', '', '', '', '', ''),
(38, 'Choose Target Ship', 'Ship', 1, 1, '', '', '', '', '', '', '', '', '');

-- --------------------------------------------------------

--
-- Table structure for table `triggers`
--

CREATE TABLE `triggers` (
  `triggerid` int(10) UNSIGNED NOT NULL,
  `log` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `zone` enum('play','graveyard','discard','deck','hand') NOT NULL DEFAULT 'play',
  `oneshot` tinyint(4) NOT NULL DEFAULT '0',
  `targettype` varchar(255) NOT NULL,
  `targetindex` int(11) NOT NULL,
  `trigger1` varchar(255) NOT NULL,
  `compare1` varchar(5) NOT NULL,
  `target1` varchar(255) NOT NULL,
  `trigger2` varchar(255) NOT NULL,
  `compare2` varchar(5) NOT NULL,
  `target2` varchar(255) NOT NULL,
  `trigger3` varchar(255) NOT NULL,
  `compare3` varchar(10) NOT NULL,
  `target3` varchar(255) NOT NULL,
  `effecttype` varchar(255) NOT NULL,
  `effecttarget` varchar(255) NOT NULL,
  `effectmod1` varchar(255) NOT NULL,
  `effectindexes` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `triggers`
--

INSERT INTO `triggers` (`triggerid`, `log`, `type`, `zone`, `oneshot`, `targettype`, `targetindex`, `trigger1`, `compare1`, `target1`, `trigger2`, `compare2`, `target2`, `trigger3`, `compare3`, `target3`, `effecttype`, `effecttarget`, `effectmod1`, `effectindexes`) VALUES
(1, '', 'Shiptrained', 'play', 0, 'single', 1, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '4'),
(2, '', 'Shiptrained', 'play', 0, 'single', 1, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '5'),
(3, '', 'Shiptrained', 'play', 0, 'single', 1, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '6'),
(4, '', 'Shiptrained', 'play', 0, 'single', 1, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '7'),
(5, '', 'Shiptrained', 'play', 0, 'single', 1, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '8'),
(6, '', 'Shiptrained', 'play', 0, 'single', 1, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '9'),
(7, '', 'Shiptrained', 'play', 0, 'single', 1, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '11'),
(8, '', 'Shiptrained', 'play', 0, 'single', 1, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '12'),
(9, '', 'Shiptrained', 'play', 0, 'single', 1, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '13'),
(10, '%name% draws a card.', 'startturn', 'play', 0, 'controller', 0, 'self.owner', '=', 'core.turn', '', '', '', '', '', '', 'draw', 'controller', '1', ''),
(11, '%name% draws two cards.', 'startturn', 'play', 0, 'controller', 0, 'self.owner', '=', 'core.turn', '', '', '', '', '', '', 'draw', 'controller', '2', ''),
(12, '%name% draws three cards.', 'startturn', 'play', 0, 'controller', 0, 'self.owner', '=', 'core.turn', '', '', '', '', '', '', 'draw', 'controller', '3', ''),
(13, '%name% levels a card', 'Shiptrained', 'play', 0, 'cardinhand', 3, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '14'),
(14, '%name% spews destruction everywhere', 'startturn', 'play', 0, 'opponent', 0, 'core.turn', '=', 'self.owner', '', '', '', '', '', '', 'Damage', 'opponent', '2', ''),
(15, '%name% spews destruction everywhere', 'startturn', 'play', 0, 'opponent', 0, 'core.turn', '=', 'self.owner', '', '', '', '', '', '', 'Damage', 'opponent', '4', ''),
(16, '%name% spews destruction everywhere', 'startturn', 'play', 0, 'opponent', 0, 'core.turn', '=', 'self.owner', '', '', '', '', '', '', 'Damage', 'opponent', '6', ''),
(17, '%name% spreads life force.', 'startturn', 'play', 0, 'controller', 0, 'core.turn', '=', 'self.owner', '', '', '', '', '', '', 'heal', 'controller', '2', ''),
(18, '%name% spreads life force.', 'startturn', 'play', 0, 'controller', 0, 'core.turn', '=', 'self.owner', '', '', '', '', '', '', 'heal', 'controller', '4', ''),
(19, '%name% spreads life force.', 'startturn', 'play', 0, 'controller', 0, 'core.turn', '=', 'self.owner', '', '', '', '', '', '', 'heal', 'controller', '6', ''),
(20, '', 'healed', 'play', 0, '', 0, 'target.id', '=', 'self.owner', '', '', '', '', '', '', 'draw', 'controller', '1', ''),
(21, '%name% heals', 'Shiptrained', 'play', 0, 'controller', 1, 'self.id', '=', 'target.id', '', '', '', '', '', '', 'heal', 'controller', '5', ''),
(22, '%name% heals', 'Shiptrained', 'play', 0, 'controller', 1, 'self.id', '=', 'target.id', '', '', '', '', '', '', 'heal', 'controller', '10', ''),
(23, '%name% heals', 'Shiptrained', 'play', 0, 'controller', 1, 'self.id', '=', 'target.id', '', '', '', '', '', '', 'heal', 'controller', '15', ''),
(24, '%name% Launches a support ship', 'healed', 'play', 0, '', 0, 'target.id', '=', 'self.owner', '', '', '', '', '', '', 'Spawn', 'randomemptylane', '96', ''),
(25, '%name% Launches a support ship', 'healed', 'play', 0, '', 0, 'target.id', '=', 'self.owner', '', '', '', '', '', '', 'Spawn', 'randomemptylane', '97', ''),
(26, '%name% Launches a support ship', 'healed', 'play', 0, '', 0, 'target.id', '=', 'self.owner', '', '', '', '', '', '', 'Spawn', 'randomemptylane', '98', ''),
(27, '', 'Shiptrained', 'play', 0, 'single', 5, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '15'),
(28, '', 'Shiptrained', 'play', 0, 'single', 5, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '16'),
(29, '', 'Shiptrained', 'play', 0, 'single', 5, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '17'),
(30, '%name% turns into a spirit', 'died', 'graveyard', 0, '', 0, 'self.id', '=', 'target.id', '', '', '', '', '', '', 'Spawn', 'randomemptylane', '111', ''),
(31, '%name% turns into a spirit', 'died', 'graveyard', 0, '', 0, 'self.id', '=', 'target.id', '', '', '', '', '', '', 'Spawn', 'randomemptylane', '112', ''),
(32, '%name% turns into a spirit', 'died', 'graveyard', 0, '', 0, 'self.id', '=', 'target.id', '', '', '', '', '', '', 'Spawn', 'randomemptylane', '113', ''),
(33, '%name% leaves destruction in it\'s wake', 'died', 'graveyard', 0, '', 0, 'self.id', '=', 'target.id', '', '', '', '', '', '', 'Damage', 'opponent', '3', ''),
(34, '%name% leaves destruction in it\'s wake', 'died', 'graveyard', 0, '', 0, 'self.id', '=', 'target.id', '', '', '', '', '', '', 'Damage', 'opponent', '6', ''),
(35, '%name% leaves destruction in it\'s wake', 'died', 'graveyard', 0, '', 0, 'self.id', '=', 'target.id', '', '', '', '', '', '', 'Damage', 'opponent', '9', ''),
(36, '%name% generates a doomwake', 'Shiptrained', 'play', 0, '', 0, 'target.subtype', 'eq', 'value.Doomwake', 'self.owner', '=', 'target.owner', '', '', '', 'Damage', 'opponent', '2', ''),
(37, '%name% generates a doomwake', 'Shiptrained', 'play', 0, '', 0, 'target.subtype', 'eq', 'value.Doomwake', 'self.owner', '=', 'target.owner', '', '', '', 'Damage', 'opponent', '3', ''),
(38, '%name% generates a doomwake', 'Shiptrained', 'play', 0, '', 0, 'target.subtype', 'eq', 'value.Doomwake', 'self.owner', '=', 'target.owner', '', '', '', 'Damage', 'opponent', '4', ''),
(39, '%name% generates a doomwake', 'died', 'play', 0, '', 0, 'target.subtype', 'eq', 'value.Doomwake', 'self.owner', '=', 'target.owner', '', '', '', 'Damage', 'opponent', '2', ''),
(40, '%name% generates a doomwake', 'died', 'play', 0, '', 0, 'target.subtype', 'eq', 'value.Doomwake', 'self.owner', '=', 'target.owner', '', '', '', 'Damage', 'opponent', '3', ''),
(41, '%name% generates a doomwake', 'died', 'play', 0, '', 0, 'target.subtype', 'eq', 'value.Doomwake', 'self.owner', '=', 'target.owner', '', '', '', 'Damage', 'opponent', '4', ''),
(42, '%name% pays the commision on another ship', 'Shiptrained', 'play', 0, 'cardinhand', 6, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '21'),
(43, '%name% pays the commision on another ship', 'Shiptrained', 'play', 0, 'cardinhand', 8, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '21'),
(44, '%name% fires', 'Shiptrained', 'play', 0, 'single', 5, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '46'),
(45, '%name% fires', 'Shiptrained', 'play', 0, 'single', 5, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '47'),
(46, '%name% fires', 'Shiptrained', 'play', 0, 'single', 5, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '48'),
(47, '%name% Prepares an effect', 'Shiptrained', 'play', 0, 'cardinhand', 10, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '52'),
(48, '%name% Prepares an effect', 'Shiptrained', 'play', 0, 'cardinhand', 11, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '52'),
(49, '%name% revels in the death', 'died', 'play', 0, '', 0, '', '', '', '', '', '', '', '', '', 'stats', 'self', '+1/+1', ''),
(50, '%name% revels in the death', 'died', 'play', 0, '', 0, '', '', '', '', '', '', '', '', '', 'stats', 'self', '+2/+2', ''),
(51, '%name% revels in the death', 'died', 'play', 0, '', 0, '', '', '', '', '', '', '', '', '', 'stats', 'self', '+3/+3', ''),
(52, '%name% is loyal', 'Shiptrained', 'play', 0, '', 0, 'self.id', '=', 'target.id', 'self.factioninhand.Helkinite', '>=', 'value.4', '', '', '', 'stats', 'self', '+4/+4', ''),
(53, '%name% is loyal', 'Shiptrained', 'play', 0, 'single', 5, 'self.id', '=', 'target.id', 'self.factioninhand.Mars', '>=', 'value.4', '', '', '', 'Damage', 'target0', '1-4', ''),
(54, '%name% is loyal', 'Shiptrained', 'play', 0, 'single', 5, 'self.id', '=', 'target.id', 'self.factioninhand.Mars', '>=', 'value.4', '', '', '', 'Damage', 'target0', '2-8', ''),
(55, '%name% is loyal', 'Shiptrained', 'play', 0, 'single', 5, 'self.id', '=', 'target.id', 'self.factioninhand.Mars', '>=', 'value.4', '', '', '', 'Damage', 'target0', '3-16', ''),
(56, '%name% is loyal', 'Shiptrained', 'play', 0, 'all', 7, 'self.id', '=', 'target.id', 'self.factioninhand.Dralk', '>=', 'value.4', '', '', '', 'keyword', 'Repair', '2', ''),
(57, '%name% is loyal', 'Shiptrained', 'play', 0, 'all', 7, 'self.id', '=', 'target.id', 'self.factioninhand.Dralk', '>=', 'value.4', '', '', '', 'keyword', 'Repair', '4', ''),
(58, '%name% is loyal', 'Shiptrained', 'play', 0, 'all', 7, 'self.id', '=', 'target.id', 'self.factioninhand.Dralk', '>=', 'value.4', '', '', '', 'keyword', 'Repair', '6', ''),
(59, '%name% is loyal', 'Shiptrained', 'play', 0, 'cardinhand', 16, 'self.id', '=', 'target.id', 'self.factioninhand.Earth', '>=', 'value.4', '', '', '', 'keyword', '', '', '59'),
(60, '%name% pumps the center', 'Shiptrained', 'play', 0, '', 0, 'target.lane', '=', 'value.3', 'self.owner', '=', 'target.owner', '', '', '', 'stats', 'target1', '+2/+2', ''),
(61, '%name% pumps the center', 'Shiptrained', 'play', 0, '', 0, 'target.lane', '=', 'value.3', 'self.owner', '=', 'target.owner', '', '', '', 'stats', 'target1', '+4/+4', ''),
(62, '%name% pumps the center', 'Shiptrained', 'play', 0, '', 0, 'target.lane', '=', 'value.3', 'self.owner', '=', 'target.owner', '', '', '', 'stats', 'target1', '+6/+6', ''),
(63, '%name% pumps the edge', 'Shiptrained', 'play', 0, '', 0, 'target.lane', '=', 'value.5', 'self.owner', '=', 'target.owner', '', '', '', 'stats', 'target1', '+2/+2', ''),
(64, '%name% pumps the edge', 'Shiptrained', 'play', 0, '', 0, 'target.lane', '=', 'value.1', 'self.owner', '=', 'target.owner', '', '', '', 'stats', 'target1', '+2/+2', ''),
(65, '%name% pumps the edge', 'Shiptrained', 'play', 0, '', 0, 'target.lane', '=', 'value.1', 'self.owner', '=', 'target.owner', '', '', '', 'keyword', 'target1', 'Repair 1', ''),
(66, '%name% pumps the edge', 'Shiptrained', 'play', 0, '', 0, 'target.lane', '=', 'value.5', 'self.owner', '=', 'target.owner', '', '', '', 'keyword', 'target1', 'Repair 1', ''),
(67, '%name% Brings it\'s twin', 'Shiptrained', 'play', 0, '', 0, 'self.id', '=', 'target.id', '', '', '', '', '', '', 'Spawn', 'randomemptylane', '194', ''),
(68, '%name% Brings it\'s twin', 'Shiptrained', 'play', 0, '', 0, 'self.id', '=', 'target.id', '', '', '', '', '', '', 'Spawn', 'randomemptylane', '195', ''),
(69, '%name% Brings it\'s twin', 'Shiptrained', 'play', 0, '', 0, 'self.id', '=', 'target.id', '', '', '', '', '', '', 'Spawn', 'randomemptylane', '196', ''),
(70, '%name% triggers', 'Shiptrained', 'play', 0, 'allcards', 17, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '63'),
(73, '%name% triggers', 'Shiptrained', 'play', 0, 'allcards', 18, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '63'),
(74, '%name% triggers', 'Shiptrained', 'play', 0, 'allcards', 19, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '63'),
(75, '%name% rigs the future', 'Shiptrained', 'play', 0, 'allcards', 20, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '62'),
(76, '%name% rigs the future', 'Shiptrained', 'play', 0, 'allcards', 21, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '62'),
(77, '%name% rigs the future', 'Shiptrained', 'play', 0, 'allcards', 22, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '62'),
(78, '%name% triggers', 'Shiptrained', 'play', 0, 'single', 26, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '69'),
(79, '%name% pumps the edge', 'Shiptrained', 'play', 0, '', 0, 'target.lane', '=', 'value.5', 'self.owner', '=', 'target.owner', '', '', '', 'keyword', 'target1', 'Repair 2', ''),
(80, '%name% pumps the edge', 'Shiptrained', 'play', 0, '', 0, 'target.lane', '=', 'value.1', 'self.owner', '=', 'target.owner', '', '', '', 'keyword', 'target1', 'Repair 2', ''),
(81, '%name% pumps the edge', 'Shiptrained', 'play', 0, '', 0, 'target.lane', '=', 'value.1', 'self.owner', '=', 'target.owner', '', '', '', 'stats', 'target1', '+3/+3', ''),
(82, '%name% pumps the edge', 'Shiptrained', 'play', 0, '', 0, 'target.lane', '=', 'value.5', 'self.owner', '=', 'target.owner', '', '', '', 'stats', 'target1', '+3/+3', ''),
(83, '%name% pumps the edge', 'Shiptrained', 'play', 0, '', 0, 'target.lane', '=', 'value.5', 'self.owner', '=', 'target.owner', '', '', '', 'keyword', 'target1', 'Repair 3', ''),
(84, '%name% pumps the edge', 'Shiptrained', 'play', 0, '', 0, 'target.lane', '=', 'value.1', 'self.owner', '=', 'target.owner', '', '', '', 'keyword', 'target1', 'Repair 3', ''),
(85, '%name% pumps the edge', 'Shiptrained', 'play', 0, '', 0, 'target.lane', '=', 'value.1', 'self.owner', '=', 'target.owner', '', '', '', 'stats', 'target1', '+4/+4', ''),
(86, '%name% pumps the edge', 'Shiptrained', 'play', 0, '', 0, 'target.lane', '=', 'value.5', 'self.owner', '=', 'target.owner', '', '', '', 'stats', 'target1', '+4/+4', ''),
(87, '%name% rediscovers the past', 'Shiptrained', 'play', 0, 'allcards', 31, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '72'),
(88, '%name% rediscovers the past', 'Shiptrained', 'play', 0, 'allcards', 32, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '72'),
(89, '%name% rediscovers the past', 'Shiptrained', 'play', 0, 'allcards', 33, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '72'),
(90, '%name% steals a card', 'Shiptrained', 'play', 0, 'allcards', 34, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '73'),
(91, '%name% steals a card', 'Shiptrained', 'play', 0, 'allcards', 35, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '73'),
(92, '%name% steals a card', 'Shiptrained', 'play', 0, 'allcards', 36, 'self.id', '=', 'target.id', '', '', '', '', '', '', '', '', '', '73'),
(93, '%name% starts falling apart', 'Shiptrained', 'play', 0, '', 0, 'self.lane', '=', 'target.lane', 'self.id', '!=', 'target.id', '', '', '', 'keyword', 'self', 'Decay 2', ''),
(94, '%name% starts falling apart', 'Shiptrained', 'play', 0, '', 0, 'self.lane', '=', 'target.lane', 'self.id', '!=', 'target.id', '', '', '', 'keyword', 'self', 'Decay 4', ''),
(95, '%name% starts falling apart', 'Shiptrained', 'play', 0, '', 0, 'self.lane', '=', 'target.lane', 'self.id', '!=', 'target.id', '', '', '', 'keyword', 'self', 'Decay 6', ''),
(96, '%name% Recycles the debris', 'died', 'play', 0, '', 0, '', '', '', '', '', '', '', '', '', 'heal', 'controller', '2', ''),
(97, '%name% Recycles the debris', 'died', 'play', 0, '', 0, '', '', '', '', '', '', '', '', '', 'heal', 'controller', '4', ''),
(98, '%name% Recycles the debris', 'died', 'play', 0, '', 0, '', '', '', '', '', '', '', '', '', 'heal', 'controller', '8', ''),
(99, '%name% learns much', 'Shiptrained', 'play', 0, '', 0, 'self.id', '=', 'target.id', 'self.controller.level', '>=', 'value.2', '', '', '', 'draw', 'controller', '2', ''),
(100, '%name% learns much', 'Shiptrained', 'play', 0, '', 0, 'self.id', '=', 'target.id', 'self.controller.level', '>=', 'value.3', '', '', '', 'draw', 'controller', '4', ''),
(101, '%name% learns much', 'Shiptrained', 'play', 0, '', 0, 'self.id', '=', 'target.id', 'self.controller.level', '>=', 'value.4', '', '', '', 'draw', 'controller', '6', ''),
(102, '%name% reinforces', 'Shiptrained', 'play', 0, 'single', 1, 'self.id', '=', 'target.id', 'self.controller.level', '>=', 'value.2', '', '', '', '', '', '', '93'),
(103, '%name% reinforces', 'Shiptrained', 'play', 0, 'single', 1, 'self.id', '=', 'target.id', 'self.controller.level', '>=', 'value.2', '', '', '', '', '', '', '94'),
(104, '%name% reinforces', 'Shiptrained', 'play', 0, 'single', 1, 'self.id', '=', 'target.id', 'self.controller.level', '>=', 'value.3', '', '', '', '', '', '', '95'),
(105, '%name% reinforces', 'Shiptrained', 'play', 0, 'single', 1, 'self.id', '=', 'target.id', 'self.controller.level', '>=', 'value.4', '', '', '', '', '', '', '94'),
(106, '%name% reinforces', 'Shiptrained', 'play', 0, 'single', 5, 'self.id', '=', 'target.id', 'self.controller.level', '>=', 'value.2', '', '', '', '', '', '', '96'),
(107, '%name% reinforces', 'Shiptrained', 'play', 0, 'single', 5, 'self.id', '=', 'target.id', 'self.controller.level', '>=', 'value.3', '', '', '', '', '', '', '97'),
(108, '%name% reinforces', 'Shiptrained', 'play', 0, 'single', 5, 'self.id', '=', 'target.id', 'self.controller.level', '>=', 'value.4', '', '', '', '', '', '', '98'),
(109, '%name% shrinks an enemy', 'Shiptrained', 'play', 0, 'single', 5, 'self.id', '=', 'target.id', 'self.controller.level', '>=', 'value.2', '', '', '', '', '', '', '99'),
(110, '%name% shrinks an enemy', 'Shiptrained', 'play', 0, 'single', 5, 'self.id', '=', 'target.id', 'self.controller.level', '>=', 'value.3', '', '', '', '', '', '', '100'),
(111, '%name% shrinks an enemy', 'Shiptrained', 'play', 0, 'single', 5, 'self.id', '=', 'target.id', 'self.controller.level', '>=', 'value.4', '', '', '', '', '', '', '101'),
(112, '%name% launches a drone', 'Shiptrained', 'play', 0, '', 0, 'self.id', '=', 'target.id', '', '', '', '', '', '', 'Spawn', 'randomemptylane', '279', ''),
(113, '%name% launches a drone', 'Shiptrained', 'play', 0, '', 0, 'self.id', '=', 'target.id', '', '', '', '', '', '', 'Spawn', 'randomemptylane', '280', ''),
(114, '%name% launches a drone', 'Shiptrained', 'play', 0, '', 0, 'self.id', '=', 'target.id', '', '', '', '', '', '', 'Spawn', 'randomemptylane', '281', '');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Activated`
--
ALTER TABLE `Activated`
  ADD PRIMARY KEY (`ActivateId`);

--
-- Indexes for table `carddata`
--
ALTER TABLE `carddata`
  ADD PRIMARY KEY (`CardId`);

--
-- Indexes for table `effects`
--
ALTER TABLE `effects`
  ADD PRIMARY KEY (`effectid`);

--
-- Indexes for table `static`
--
ALTER TABLE `static`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `targets`
--
ALTER TABLE `targets`
  ADD PRIMARY KEY (`targetid`);

--
-- Indexes for table `triggers`
--
ALTER TABLE `triggers`
  ADD PRIMARY KEY (`triggerid`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Activated`
--
ALTER TABLE `Activated`
  MODIFY `ActivateId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
--
-- AUTO_INCREMENT for table `carddata`
--
ALTER TABLE `carddata`
  MODIFY `CardId` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=285;
--
-- AUTO_INCREMENT for table `effects`
--
ALTER TABLE `effects`
  MODIFY `effectid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=102;
--
-- AUTO_INCREMENT for table `static`
--
ALTER TABLE `static`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `targets`
--
ALTER TABLE `targets`
  MODIFY `targetid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;
--
-- AUTO_INCREMENT for table `triggers`
--
ALTER TABLE `triggers`
  MODIFY `triggerid` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=115;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
