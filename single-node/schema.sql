CREATE TABLE `group` (
    `id` bigint unsigned NOT NULL AUTO_INCREMENT,
    `name` varchar(100) CHARACTER
    SET
        utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
        PRIMARY KEY (`id`),
        UNIQUE KEY `name_unique` (`name`),
        CONSTRAINT `group_name_check` CHECK ((`name` <> _utf8mb4 ''))
) ENGINE = InnoDB AUTO_INCREMENT = 29 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `agent` (
    `id` bigint unsigned NOT NULL AUTO_INCREMENT,
    `group_id` bigint unsigned NOT NULL,
    `wazuh_agent_id` varchar(8) CHARACTER
    SET
        utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
        `name` varchar(128) CHARACTER
    SET
        utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
        `ip` varchar(19) CHARACTER
    SET
        utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
        `agent_key` varchar(128) CHARACTER
    SET
        utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
        PRIMARY KEY (`id`),
        KEY `agent_group_FK` (`group_id`) USING BTREE,
        CONSTRAINT `agent_group_FK` FOREIGN KEY (`group_id`) REFERENCES `group` (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 6 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `sensor` (
    `id` bigint unsigned NOT NULL AUTO_INCREMENT,
    `group_id` bigint unsigned NOT NULL,
    `last_connected` datetime DEFAULT NULL,
    `name` varchar(100) CHARACTER
    SET
        utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
        `auth_key` varchar(255) CHARACTER
    SET
        utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
        PRIMARY KEY (`id`),
        KEY `sensor_group_FK` (`group_id`) USING BTREE,
        CONSTRAINT `sensor_group_FK` FOREIGN KEY (`group_id`) REFERENCES `group` (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 5 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE `asset` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `group_id` bigint unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `mac_address` varchar(255) NOT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `last_seen` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `group_id` (`group_id`,`name`),
  UNIQUE KEY `mac_address` (`mac_address`),
  CONSTRAINT `asset_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
