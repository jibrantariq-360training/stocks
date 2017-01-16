-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Jan 16, 2017 at 07:47 AM
-- Server version: 10.1.13-MariaDB
-- PHP Version: 5.5.35

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `stocks`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `action_sp` (IN `a_name` VARCHAR(255), IN `action_type` VARCHAR(255), IN `a_id` INT, OUT `o_value` INT)  NO SQL
BEGIN

IF action_type = 'INSERT' THEN

INSERT INTO action (`action_name`) VALUES (a_name);

SELECT MAX(action_id) into o_value from action;

END IF;

IF action_type = 'UPDATE' THEN

UPDATE action SET action_name = a_name , updated_on = CURRENT_TIMESTAMP where action_id = a_id;

END IF;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `scrip_sp` (IN `a_name` VARCHAR(255), IN `action_type` VARCHAR(255), IN `a_id` INT, OUT `o_value` INT)  NO SQL
BEGIN

IF action_type = 'INSERT' THEN

INSERT INTO scrip (`scrip_name`) VALUES (a_name);

SELECT MAX(scrip_id) INTO o_value FROM scrip;

END IF;

IF action_type = 'UPDATE' THEN

UPDATE scrip SET scrip_name = a_name , updated_on = CURRENT_TIMESTAMP where scrip_id = a_id;

END IF;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `subtransaction_sp` (IN `i_action_name` INT(255), IN `i_scrip` INT(255), IN `i_price` DECIMAL(10,2), IN `i_qty` INT(11), IN `i_a_value` DECIMAL(20,2), IN `i_balance` DECIMAL(20,2), IN `i_transaction_id` INT(255), IN `i_user_id` INT(255), IN `i_buy_transaction_id` INT(255))  NO SQL
BEGIN
DECLARE t_sub_id INT;
DECLARE user_tval INT;

INSERT INTO `subtransaction`(`transaction_id`, `user_id`) VALUES (i_transaction_id,i_user_id);

SELECT MAX(id) INTO t_sub_id FROM subtransaction;

INSERT INTO `subtransaction_log`(`id`, `action_id`, `scrip_id`, `actual_value`, `qty`, `balance`) VALUES (t_sub_id,i_action_name,i_scrip,i_a_value,i_qty,i_balance);


IF i_action_name = 1 THEN 

SELECT COUNT(id) INTO user_tval FROM users_scrip_qty WHERE user_id = i_user_id AND scrip_id = i_scrip AND price = i_price ;

ELSEIF i_action_name = 3 THEN 

SELECT COUNT(id) INTO user_tval FROM users_scrip_qty WHERE user_id = i_user_id AND scrip_id = i_scrip;

END IF;

IF user_tval = 0 AND i_qty <> 0 THEN

INSERT INTO `users_scrip_qty`(`user_id`, `scrip_id`, `qty`,`price`) VALUES (i_user_id,i_scrip,i_qty,i_price);
INSERT INTO `transaction_scrip_qty`(`transaction_id`, `user_id`, `qty`) VALUES (i_transaction_id,i_user_id,i_qty);

ELSEIF i_qty <> 0 THEN
IF i_action_name = 1 THEN 
UPDATE users_scrip_qty SET qty = qty + i_qty WHERE user_id = i_user_id AND scrip_id = i_scrip AND price = i_price ;
INSERT INTO `transaction_scrip_qty`(`transaction_id`, `user_id`, `qty`) VALUES (i_transaction_id,i_user_id,i_qty);
ELSEIF i_action_name = 3 THEN 
UPDATE users_scrip_qty SET qty = qty - i_qty WHERE user_id = i_user_id AND scrip_id = i_scrip ;

END IF; 
END IF; 
SELECT COUNT(id) INTO user_tval FROM users_balance WHERE user_id = i_user_id;

IF user_tval = 0 THEN 

INSERT INTO `users_balance`(`user_id`, `balance`) VALUES (i_user_id,i_balance);

ELSE

UPDATE users_balance SET balance= balance + i_a_value WHERE user_id = i_user_id;

END IF; 

UPDATE transaction t set t.completed = 1 where t.transaction_id = i_transaction_id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `transaction_scrip_qty_sp` (IN `i_user_id` INT(255), IN `i_buy_transaction_id` INT(255), IN `i_qty` INT(11))  NO SQL
BEGIN

UPDATE transaction_scrip_qty set qty = qty - i_qty where user_id = i_user_id and transaction_id = i_buy_transaction_id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `transaction_sp` (IN `i_action_name` VARCHAR(255), IN `i_scrip` VARCHAR(255), IN `i_price` DECIMAL(10,2), IN `i_qty` INT(11), IN `i_tax1` FLOAT(10,3), IN `i_tax2` FLOAT(10,3), IN `i_comission` FLOAT(10,3), IN `i_a_value` DECIMAL(20,2), IN `i_balance` DECIMAL(20,2), OUT `o_transaction_id` INT, IN `action_type` VARCHAR(255), IN `i_transaction_id` INT(255))  NO SQL
BEGIN
DECLARE s_value INT;
DECLARE a_value INT;
DECLARE t_value INT;


SELECT scrip_id INTO s_value FROM scrip WHERE scrip_name like i_scrip;

IF s_value IS NULL THEN 

INSERT INTO scrip(scrip_name) VALUES (i_scrip);

SELECT MAX(scrip_id) into s_value FROM scrip;

END IF;

SELECT action_id INTO a_value FROM action WHERE action_name like i_action_name;

IF a_value IS NULL THEN 

INSERT INTO action(action_name) VALUES (i_action_name);

SELECT MAX(action_id) into a_value FROM action;

END IF;

IF action_type = 'INSERT' THEN

INSERT INTO transaction (action_id, scrip_id, balance) VALUES (a_value, s_value, i_balance);

SELECT MAX(transaction_id) into t_value from transaction;

INSERT INTO transaction_log (transaction_id, price, qty, tax1, tax2, comission, a_value) VALUES (t_value, i_price, i_qty, i_tax1, i_tax2,i_comission,i_a_value);

END IF;

IF action_type = 'UPDATE' THEN
UPDATE transaction SET action_id = a_value, scrip_id = s_value, balance = i_balance WHERE transaction_id = i_transaction_id;

UPDATE transaction_log SET price = i_price, qty = i_qty, tax1 = i_tax1, tax2 = i_tax2, comission = i_comission, a_value = a_value 
WHERE transaction_id = i_transaction_id;



END IF;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `action`
--

CREATE TABLE `action` (
  `action_id` int(255) NOT NULL,
  `action_name` varchar(255) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `action`
--

INSERT INTO `action` (`action_id`, `action_name`, `created_on`, `updated_on`) VALUES
(1, 'BUY', '2017-01-10 11:31:45', NULL),
(2, 'CASH Withdraw', '2017-01-10 12:07:20', NULL),
(3, 'SELL', '2017-01-10 12:19:20', NULL),
(4, 'CASH Inject', '2017-01-10 12:39:25', NULL),
(5, 'CDC Deduction', '2017-01-10 12:49:15', NULL);

--
-- Triggers `action`
--
DELIMITER $$
CREATE TRIGGER `action_update_trigger` AFTER UPDATE ON `action` FOR EACH ROW BEGIN
IF
    (
      OLD.action_name <> NEW.action_name
    ) THEN
  INSERT
INTO
  audit_table(
    table_name,
    action,
    new_value,
    old_value
  )
VALUES(
  'ACTION',
  'UPDATE',
  NEW.action_name,
  OLD.action_name
);
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `audit_table`
--

CREATE TABLE `audit_table` (
  `audit_id` int(255) NOT NULL,
  `table_name` varchar(255) NOT NULL,
  `action` varchar(255) NOT NULL,
  `new_value` varchar(255) NOT NULL,
  `old_value` varchar(255) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `scrip`
--

CREATE TABLE `scrip` (
  `scrip_id` int(255) NOT NULL,
  `scrip_name` varchar(255) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_on` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `scrip`
--

INSERT INTO `scrip` (`scrip_id`, `scrip_name`, `created_on`, `updated_on`) VALUES
(1, '', '2017-01-12 14:07:04', NULL),
(2, 'MTL', '2017-01-12 14:07:40', NULL),
(3, 'SYS', '2017-01-12 14:22:59', NULL),
(4, 'MLT', '2017-01-13 09:44:40', NULL),
(5, 'EFOODS', '2017-01-13 11:07:03', NULL);

--
-- Triggers `scrip`
--
DELIMITER $$
CREATE TRIGGER `scrip_update_trigger` AFTER UPDATE ON `scrip` FOR EACH ROW BEGIN
       IF (OLD.scrip_name <> NEW.scrip_name) THEN
          INSERT INTO audit_table(table_name,action,new_value,old_value)
		  VALUES('SCRIP','UPDATE',NEW.scrip_name,OLD.scrip_name);
       END IF;
    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `subtransaction`
--

CREATE TABLE `subtransaction` (
  `id` int(255) NOT NULL,
  `transaction_id` int(255) NOT NULL,
  `user_id` int(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `subtransaction`
--

INSERT INTO `subtransaction` (`id`, `transaction_id`, `user_id`) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 2, 1),
(4, 3, 2),
(5, 4, 1),
(6, 4, 2);

-- --------------------------------------------------------

--
-- Table structure for table `subtransaction_log`
--

CREATE TABLE `subtransaction_log` (
  `id` int(255) NOT NULL,
  `action_id` int(255) NOT NULL,
  `scrip_id` int(255) NOT NULL,
  `actual_value` decimal(20,2) NOT NULL,
  `qty` int(11) DEFAULT NULL,
  `balance` decimal(20,2) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `subtransaction_log`
--

INSERT INTO `subtransaction_log` (`id`, `action_id`, `scrip_id`, `actual_value`, `qty`, `balance`, `created_on`, `updated_on`) VALUES
(1, 4, 1, '500000.00', 0, '500000.00', '2017-01-14 18:23:00', NULL),
(2, 4, 1, '500000.00', 0, '500000.00', '2017-01-14 18:23:00', NULL),
(3, 1, 5, '-75039.50', 500, '424960.50', '2017-01-14 18:23:33', NULL),
(4, 1, 5, '-77540.75', 500, '422459.25', '2017-01-14 18:23:52', NULL),
(5, 3, 5, '79958.33', 500, '504918.83', '2017-01-14 18:24:28', NULL),
(6, 3, 5, '15991.67', 100, '438450.92', '2017-01-14 18:24:28', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `transaction`
--

CREATE TABLE `transaction` (
  `transaction_id` int(255) NOT NULL,
  `action_id` int(255) NOT NULL,
  `scrip_id` int(255) NOT NULL,
  `balance` decimal(20,2) NOT NULL,
  `completed` tinyint(1) NOT NULL DEFAULT '0',
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `transaction`
--

INSERT INTO `transaction` (`transaction_id`, `action_id`, `scrip_id`, `balance`, `completed`, `created_on`) VALUES
(1, 4, 1, '1000000.00', 1, '2017-01-14 18:21:57'),
(2, 1, 5, '924960.50', 1, '2017-01-14 18:22:15'),
(3, 1, 5, '847419.75', 1, '2017-01-14 18:22:27'),
(4, 3, 5, '943369.75', 1, '2017-01-14 18:22:43');

-- --------------------------------------------------------

--
-- Table structure for table `transaction_audit`
--

CREATE TABLE `transaction_audit` (
  `tranaction_id` int(255) NOT NULL,
  `c_name` varchar(255) NOT NULL,
  `action` varchar(255) NOT NULL,
  `new_value` varchar(255) NOT NULL,
  `old_value` varchar(255) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `transaction_log`
--

CREATE TABLE `transaction_log` (
  `transaction_id` int(255) NOT NULL,
  `price` decimal(20,2) DEFAULT NULL,
  `qty` int(11) DEFAULT NULL,
  `tax1` float(10,3) DEFAULT NULL,
  `tax2` float(10,3) DEFAULT NULL,
  `comission` float(10,3) DEFAULT NULL,
  `a_value` decimal(20,2) DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `transaction_log`
--

INSERT INTO `transaction_log` (`transaction_id`, `price`, `qty`, `tax1`, `tax2`, `comission`, `a_value`, `created_on`, `updated_on`) VALUES
(1, '0.00', 0, 0.000, 0.000, 0.000, '1000000.00', '2017-01-14 18:21:57', NULL),
(2, '150.00', 500, 1.000, 1.000, 37.500, '-75039.50', '2017-01-14 18:22:15', NULL),
(3, '155.00', 500, 1.000, 1.000, 38.750, '-77540.75', '2017-01-14 18:22:27', NULL),
(4, '160.00', 600, 1.000, 1.000, 48.000, '95950.00', '2017-01-14 18:22:43', NULL);

--
-- Triggers `transaction_log`
--
DELIMITER $$
CREATE TRIGGER `transaction_log_update_trigger` AFTER UPDATE ON `transaction_log` FOR EACH ROW BEGIN
IF (OLD.transaction_id <> NEW.transaction_id) THEN INSERT INTO transaction_audit(tranaction_id,c_name,action,new_value,old_value) VALUES(NEW.transaction_id,'TRANSACTION_LOG.TRANSACTION_ID','UPDATE',NEW.transaction_id,OLD.transaction_id); END IF;
IF (OLD.price <> NEW.price) THEN INSERT INTO transaction_audit(tranaction_id,c_name,action,new_value,old_value) VALUES(NEW.transaction_id,'TRANSACTION_LOG.PRICE','UPDATE',NEW.price,OLD.price); END IF;
IF (OLD.qty <> NEW.qty) THEN INSERT INTO transaction_audit(tranaction_id,c_name,action,new_value,old_value) VALUES(NEW.transaction_id,'TRANSACTION_LOG.QTY','UPDATE',NEW.qty,OLD.qty); END IF;
IF (OLD.tax1 <> NEW.tax1) THEN INSERT INTO transaction_audit(tranaction_id,c_name,action,new_value,old_value) VALUES(NEW.transaction_id,'TRANSACTION_LOG.TAX1','UPDATE',NEW.tax1,OLD.tax1); END IF;
IF (OLD.tax2 <> NEW.tax2) THEN INSERT INTO transaction_audit(tranaction_id,c_name,action,new_value,old_value) VALUES(NEW.transaction_id,'TRANSACTION_LOG.TAX2','UPDATE',NEW.tax2,OLD.tax2); END IF;
IF (OLD.comission <> NEW.comission) THEN INSERT INTO transaction_audit(tranaction_id,c_name,action,new_value,old_value) VALUES(NEW.transaction_id,'TRANSACTION_LOG.COMISSION','UPDATE',NEW.comission,OLD.comission); END IF;
IF (OLD.a_value <> NEW.a_value) THEN INSERT INTO transaction_audit(tranaction_id,c_name,action,new_value,old_value) VALUES(NEW.transaction_id,'TRANSACTION_LOG.A_VALUE','UPDATE',NEW.a_value,OLD.a_value); END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `transaction_scrip_qty`
--

CREATE TABLE `transaction_scrip_qty` (
  `id` int(255) NOT NULL,
  `transaction_id` int(255) NOT NULL,
  `user_id` int(11) NOT NULL,
  `qty` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `transaction_scrip_qty`
--

INSERT INTO `transaction_scrip_qty` (`id`, `transaction_id`, `user_id`, `qty`) VALUES
(1, 2, 1, 0),
(2, 3, 2, 400);

-- --------------------------------------------------------

--
-- Stand-in structure for view `transaction_users_view`
--
CREATE TABLE `transaction_users_view` (
`transaction_id` int(255)
,`name` varchar(255)
,`qty` int(11)
,`balance` decimal(20,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `transaction_view`
--
CREATE TABLE `transaction_view` (
`transaction_id` int(255)
,`price` decimal(20,2)
,`qty` int(11)
,`tax1` float(10,3)
,`tax2` float(10,3)
,`comission` float(10,3)
,`a_value` decimal(20,2)
,`created_on` timestamp
,`action_name` varchar(255)
,`scrip_name` varchar(255)
,`completed` tinyint(1)
,`balance` decimal(20,2)
,`action_id` int(255)
,`scrip_id` int(255)
);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `closed` tinyint(1) NOT NULL DEFAULT '0',
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_on` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `phone`, `email`, `closed`, `created_on`, `updated_on`) VALUES
(1, 'Salman\r\n', '165461', 'jibrantk@hotmail.com', 0, '2017-01-11 13:13:00', NULL),
(2, 'Amir\r\n', '131312', 'Amir', 0, '2017-01-11 13:13:00', NULL),
(3, 'Danyal\r\n', '31312321', 'Danyal\r\n', 0, '2017-01-11 13:13:32', NULL),
(4, 'Farooq', '123123', 'Farooq', 0, '2017-01-11 13:13:32', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users_balance`
--

CREATE TABLE `users_balance` (
  `id` int(255) NOT NULL,
  `user_id` int(255) NOT NULL,
  `balance` decimal(20,2) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users_balance`
--

INSERT INTO `users_balance` (`id`, `user_id`, `balance`, `created_on`, `updated_on`) VALUES
(1, 1, '504918.83', '2017-01-14 18:23:00', NULL),
(2, 2, '438450.92', '2017-01-14 18:23:00', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users_scrip_qty`
--

CREATE TABLE `users_scrip_qty` (
  `id` int(255) NOT NULL,
  `user_id` int(255) NOT NULL,
  `scrip_id` int(255) NOT NULL,
  `qty` int(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_on` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users_scrip_qty`
--

INSERT INTO `users_scrip_qty` (`id`, `user_id`, `scrip_id`, `qty`, `price`, `created_on`, `updated_on`) VALUES
(1, 1, 5, 0, '150.00', '2017-01-14 18:23:33', NULL),
(2, 2, 5, 400, '155.00', '2017-01-14 18:23:52', NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `users_view`
--
CREATE TABLE `users_view` (
`id` int(255)
,`name` varchar(255)
,`balance` decimal(20,2)
);

-- --------------------------------------------------------

--
-- Structure for view `transaction_users_view`
--
DROP TABLE IF EXISTS `transaction_users_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `transaction_users_view`  AS  select `t`.`transaction_id` AS `transaction_id`,`u`.`name` AS `name`,`t`.`qty` AS `qty`,`u`.`balance` AS `balance` from (`transaction_scrip_qty` `t` join `users_view` `u` on((`t`.`user_id` = `u`.`id`))) ;

-- --------------------------------------------------------

--
-- Structure for view `transaction_view`
--
DROP TABLE IF EXISTS `transaction_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `transaction_view`  AS  select `t`.`transaction_id` AS `transaction_id`,`l`.`price` AS `price`,`l`.`qty` AS `qty`,`l`.`tax1` AS `tax1`,`l`.`tax2` AS `tax2`,`l`.`comission` AS `comission`,`l`.`a_value` AS `a_value`,`t`.`created_on` AS `created_on`,`a`.`action_name` AS `action_name`,`s`.`scrip_name` AS `scrip_name`,`t`.`completed` AS `completed`,`t`.`balance` AS `balance`,`a`.`action_id` AS `action_id`,`s`.`scrip_id` AS `scrip_id` from (((`transaction` `t` join `transaction_log` `l` on((`l`.`transaction_id` = `t`.`transaction_id`))) join `action` `a` on((`t`.`action_id` = `a`.`action_id`))) join `scrip` `s` on((`s`.`scrip_id` = `t`.`scrip_id`))) order by `t`.`created_on` desc ;

-- --------------------------------------------------------

--
-- Structure for view `users_view`
--
DROP TABLE IF EXISTS `users_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `users_view`  AS  select `u`.`id` AS `id`,`u`.`name` AS `name`,`ub`.`balance` AS `balance` from (`users` `u` left join `users_balance` `ub` on((`ub`.`user_id` = `u`.`id`))) where (`u`.`closed` <> 1) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `action`
--
ALTER TABLE `action`
  ADD PRIMARY KEY (`action_id`);

--
-- Indexes for table `audit_table`
--
ALTER TABLE `audit_table`
  ADD PRIMARY KEY (`audit_id`);

--
-- Indexes for table `scrip`
--
ALTER TABLE `scrip`
  ADD PRIMARY KEY (`scrip_id`);

--
-- Indexes for table `subtransaction`
--
ALTER TABLE `subtransaction`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `subtransaction_log`
--
ALTER TABLE `subtransaction_log`
  ADD UNIQUE KEY `id` (`id`);

--
-- Indexes for table `transaction`
--
ALTER TABLE `transaction`
  ADD PRIMARY KEY (`transaction_id`);

--
-- Indexes for table `transaction_log`
--
ALTER TABLE `transaction_log`
  ADD PRIMARY KEY (`transaction_id`);

--
-- Indexes for table `transaction_scrip_qty`
--
ALTER TABLE `transaction_scrip_qty`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users_balance`
--
ALTER TABLE `users_balance`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users_scrip_qty`
--
ALTER TABLE `users_scrip_qty`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `action`
--
ALTER TABLE `action`
  MODIFY `action_id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `audit_table`
--
ALTER TABLE `audit_table`
  MODIFY `audit_id` int(255) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `scrip`
--
ALTER TABLE `scrip`
  MODIFY `scrip_id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `subtransaction`
--
ALTER TABLE `subtransaction`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT for table `transaction`
--
ALTER TABLE `transaction`
  MODIFY `transaction_id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `transaction_scrip_qty`
--
ALTER TABLE `transaction_scrip_qty`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `users_balance`
--
ALTER TABLE `users_balance`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `users_scrip_qty`
--
ALTER TABLE `users_scrip_qty`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
