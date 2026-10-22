-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 15, 2026 at 06:00 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `construction_management`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AllocateComponent` (IN `compId` INT, IN `qty` INT)   BEGIN

UPDATE inventory
SET available_stock = available_stock - qty,
    allocated_stock = allocated_stock + qty
WHERE component_id = compId
AND available_stock >= qty;

END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `getAvailableStock` (`compId` INT) RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE qty INT;

    SELECT available_stock
    INTO qty
    FROM inventory
    WHERE component_id = compId;

    RETURN qty;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `allocations`
--

CREATE TABLE `allocations` (
  `allocation_id` int(11) NOT NULL,
  `scaffold_id` int(11) DEFAULT NULL,
  `project_id` int(11) NOT NULL,
  `site_id` int(11) DEFAULT NULL,
  `area_id` int(11) DEFAULT NULL,
  `allocation_date` date DEFAULT NULL,
  `return_date` date DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'Allocated',
  `rent_per_day` decimal(10,2) NOT NULL DEFAULT 0.00,
  `rent_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `actual_return_date` date DEFAULT NULL,
  `late_days` int(11) NOT NULL DEFAULT 0,
  `penalty` decimal(10,2) NOT NULL DEFAULT 0.00,
  `condition_status` varchar(20) NOT NULL DEFAULT 'Good',
  `component_id` int(11) DEFAULT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `allocations`
--

INSERT INTO `allocations` (`allocation_id`, `scaffold_id`, `project_id`, `site_id`, `area_id`, `allocation_date`, `return_date`, `status`, `rent_per_day`, `rent_amount`, `actual_return_date`, `late_days`, `penalty`, `condition_status`, `component_id`, `quantity`) VALUES
(8, 2, 4, 5, NULL, '2026-07-15', '2026-07-21', 'Returned', 100.00, 500.00, '2026-07-20', 0, 0.00, 'good', 2, 100),
(9, 2, 4, 5, NULL, '2026-07-15', '2026-07-20', 'Returned', 200.00, 1000.00, '2026-07-20', 0, 0.00, 'damaged', 1, 100);

--
-- Triggers `allocations`
--
DELIMITER $$
CREATE TRIGGER `allocate_stock` AFTER INSERT ON `allocations` FOR EACH ROW BEGIN

UPDATE components
SET available_quantity = available_quantity - NEW.quantity,
    allocated_quantity = allocated_quantity + NEW.quantity
WHERE component_id = NEW.component_id;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `return_stock` AFTER UPDATE ON `allocations` FOR EACH ROW BEGIN
    IF OLD.status <> 'Returned' AND NEW.status = 'Returned' THEN

        UPDATE inventory
        SET available_stock = available_stock + NEW.quantity,
            allocated_stock = allocated_stock - NEW.quantity
        WHERE component_id = NEW.component_id;

    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `clients`
--

CREATE TABLE `clients` (
  `client_id` int(11) NOT NULL,
  `client_name` varchar(100) NOT NULL,
  `company_name` varchar(100) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `clients`
--

INSERT INTO `clients` (`client_id`, `client_name`, `company_name`, `phone`, `email`, `address`, `created_at`) VALUES
(5, 'kevin', 'kn construct company', '123456789', 'kevin@gmail', 'ahmedabad', '2026-07-15 15:02:57');

-- --------------------------------------------------------

--
-- Table structure for table `components`
--

CREATE TABLE `components` (
  `component_id` int(11) NOT NULL,
  `scaffold_id` int(11) DEFAULT NULL,
  `component_name` varchar(100) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `component_condition` varchar(30) DEFAULT NULL,
  `rent_per_day` decimal(10,2) NOT NULL DEFAULT 0.00,
  `available_quantity` int(11) NOT NULL DEFAULT 0,
  `allocated_quantity` int(11) NOT NULL DEFAULT 0,
  `damaged_quantity` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `components`
--

INSERT INTO `components` (`component_id`, `scaffold_id`, `component_name`, `quantity`, `component_condition`, `rent_per_day`, `available_quantity`, `allocated_quantity`, `damaged_quantity`) VALUES
(1, 1, 'Scaffold Frame', 100, 'good', 0.00, 0, 0, 100),
(2, 2, 'Cross Brace', 100, 'good', 0.00, 100, 0, 0),
(3, 1, 'Scaffold Frame', 100, 'Good', 100.00, 100, 0, 0),
(4, 1, 'Cross Brace', 100, 'Good', 80.00, 100, 0, 0),
(5, 1, 'Base Jack', 100, 'Good', 60.00, 100, 0, 0),
(6, 1, 'U Head Jack', 100, 'Good', 60.00, 100, 0, 0),
(7, 1, 'Steel Plank', 100, 'Good', 120.00, 100, 0, 0),
(8, 1, 'Pipe', 100, 'Good', 70.00, 100, 0, 0),
(9, 1, 'Coupler', 100, 'Good', 30.00, 100, 0, 0),
(10, 1, 'Safety Helmet', 100, 'Good', 20.00, 100, 0, 0),
(11, 1, 'Safety Belt', 100, 'Good', 50.00, 100, 0, 0),
(12, 1, 'Safety Belt', 100, 'Good', 50.00, 100, 0, 0),
(13, 2, 'JCB', 5, 'Good', 5000.00, 5, 0, 0),
(14, 2, 'Generator', 10, 'Good', 1500.00, 10, 0, 0),
(15, 2, 'Concrete Mixer', 10, 'Good', 2000.00, 10, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

CREATE TABLE `inventory` (
  `inventory_id` int(11) NOT NULL,
  `component_id` int(11) NOT NULL,
  `total_stock` int(11) NOT NULL,
  `available_stock` int(11) NOT NULL,
  `allocated_stock` int(11) DEFAULT 0,
  `maintenance_stock` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `maintenance`
--

CREATE TABLE `maintenance` (
  `maintenance_id` int(11) NOT NULL,
  `scaffold_id` int(11) NOT NULL,
  `maintenance_date` date NOT NULL,
  `maintenance_type` varchar(50) NOT NULL,
  `status` varchar(30) NOT NULL,
  `maintenance_cost` decimal(10,2) NOT NULL DEFAULT 0.00,
  `completed_date` date DEFAULT NULL,
  `component_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `maintenance`
--

INSERT INTO `maintenance` (`maintenance_id`, `scaffold_id`, `maintenance_date`, `maintenance_type`, `status`, `maintenance_cost`, `completed_date`, `component_id`, `quantity`) VALUES
(2, 2, '2026-07-20', 'repair', 'completed', 200.00, '2026-07-21', 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

CREATE TABLE `projects` (
  `project_id` int(11) NOT NULL,
  `client_id` int(11) DEFAULT NULL,
  `project_name` varchar(100) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `estimated_cost` double NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `projects`
--

INSERT INTO `projects` (`project_id`, `client_id`, `project_name`, `start_date`, `end_date`, `status`, `created_at`, `estimated_cost`) VALUES
(4, 1, 'lj project', '2026-07-13', '2026-12-31', 'ongoing', '2026-07-15 15:03:53', 5000);

-- --------------------------------------------------------

--
-- Stand-in structure for view `project_summary`
-- (See below for the actual view)
--
CREATE TABLE `project_summary` (
`client_name` varchar(100)
,`project_name` varchar(100)
,`status` varchar(20)
,`estimated_cost` double
);

-- --------------------------------------------------------

--
-- Table structure for table `scaffolds`
--

CREATE TABLE `scaffolds` (
  `scaffold_id` int(11) NOT NULL,
  `scaffold_code` varchar(50) DEFAULT NULL,
  `scaffold_type` varchar(50) DEFAULT NULL,
  `status` varchar(30) DEFAULT NULL,
  `current_site` int(11) DEFAULT NULL,
  `current_area` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `scaffolds`
--

INSERT INTO `scaffolds` (`scaffold_id`, `scaffold_code`, `scaffold_type`, `status`, `current_site`, `current_area`) VALUES
(2, 'sc001', 'steel', 'Available', 5, 1),
(3, 'SCF001', 'Steel', 'Available', 1, NULL),
(4, 'SCF002', 'Steel', 'Available', 1, NULL),
(5, 'SCF003', 'Aluminium', 'Available', 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sites`
--

CREATE TABLE `sites` (
  `site_id` int(11) NOT NULL,
  `project_id` int(11) DEFAULT NULL,
  `site_name` varchar(100) DEFAULT NULL,
  `location` varchar(150) DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sites`
--

INSERT INTO `sites` (`site_id`, `project_id`, `site_name`, `location`, `latitude`, `longitude`) VALUES
(5, 4, 'sarkhej highway', 'enginnering buldiung', 20.1230000, 67.2100000);

-- --------------------------------------------------------

--
-- Table structure for table `site_areas`
--

CREATE TABLE `site_areas` (
  `area_id` int(11) NOT NULL,
  `site_id` int(11) DEFAULT NULL,
  `area_name` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `role`, `created_at`) VALUES
(1, 'admin', 'admin123', 'Admin', '2026-07-12 16:53:47');

-- --------------------------------------------------------

--
-- Structure for view `project_summary`
--
DROP TABLE IF EXISTS `project_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `project_summary`  AS SELECT `c`.`client_name` AS `client_name`, `p`.`project_name` AS `project_name`, `p`.`status` AS `status`, `p`.`estimated_cost` AS `estimated_cost` FROM (`clients` `c` join `projects` `p` on(`c`.`client_id` = `p`.`client_id`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `allocations`
--
ALTER TABLE `allocations`
  ADD PRIMARY KEY (`allocation_id`),
  ADD KEY `fk_alloc_project` (`project_id`),
  ADD KEY `fk_allocation_component` (`component_id`);

--
-- Indexes for table `clients`
--
ALTER TABLE `clients`
  ADD PRIMARY KEY (`client_id`);

--
-- Indexes for table `components`
--
ALTER TABLE `components`
  ADD PRIMARY KEY (`component_id`);

--
-- Indexes for table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`inventory_id`),
  ADD KEY `component_id` (`component_id`);

--
-- Indexes for table `maintenance`
--
ALTER TABLE `maintenance`
  ADD PRIMARY KEY (`maintenance_id`),
  ADD KEY `scaffold_id` (`scaffold_id`);

--
-- Indexes for table `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`project_id`);

--
-- Indexes for table `scaffolds`
--
ALTER TABLE `scaffolds`
  ADD PRIMARY KEY (`scaffold_id`);

--
-- Indexes for table `sites`
--
ALTER TABLE `sites`
  ADD PRIMARY KEY (`site_id`);

--
-- Indexes for table `site_areas`
--
ALTER TABLE `site_areas`
  ADD PRIMARY KEY (`area_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `allocations`
--
ALTER TABLE `allocations`
  MODIFY `allocation_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `clients`
--
ALTER TABLE `clients`
  MODIFY `client_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `components`
--
ALTER TABLE `components`
  MODIFY `component_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `inventory_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `maintenance`
--
ALTER TABLE `maintenance`
  MODIFY `maintenance_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `projects`
--
ALTER TABLE `projects`
  MODIFY `project_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `scaffolds`
--
ALTER TABLE `scaffolds`
  MODIFY `scaffold_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `sites`
--
ALTER TABLE `sites`
  MODIFY `site_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `site_areas`
--
ALTER TABLE `site_areas`
  MODIFY `area_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `allocations`
--
ALTER TABLE `allocations`
  ADD CONSTRAINT `fk_alloc_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`),
  ADD CONSTRAINT `fk_allocation_component` FOREIGN KEY (`component_id`) REFERENCES `components` (`component_id`);

--
-- Constraints for table `inventory`
--
ALTER TABLE `inventory`
  ADD CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`component_id`) REFERENCES `components` (`component_id`);

--
-- Constraints for table `maintenance`
--
ALTER TABLE `maintenance`
  ADD CONSTRAINT `maintenance_ibfk_1` FOREIGN KEY (`scaffold_id`) REFERENCES `scaffolds` (`scaffold_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
