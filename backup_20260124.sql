/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.6.24-MariaDB, for debian-linux-gnu (aarch64)
--
-- Host: localhost    Database: tm_db
-- ------------------------------------------------------
-- Server version	10.6.24-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES ('laravel-cache-lyh071111@naver.com|192.168.65.1','i:1;',1768662416),('laravel-cache-lyh071111@naver.com|192.168.65.1:timer','i:1768662416;',1768662416);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `post_id` bigint(20) unsigned NOT NULL,
  `content` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `parent_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `comments_user_id_foreign` (`user_id`),
  KEY `comments_post_id_foreign` (`post_id`),
  KEY `comments_parent_id_foreign` (`parent_id`),
  CONSTRAINT `comments_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `comments_post_id_foreign` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `comments_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
INSERT INTO `comments` VALUES (2,3,1,'스포티파이 추천이요','2026-01-03 14:35:12','2026-01-03 14:35:12',NULL),(3,2,1,'스포티파이로 가겠습니다','2026-01-04 11:59:59','2026-01-04 11:59:59',2),(5,2,1,'추천알고리즘도 좋고 음질도 좋네요 감사합니다','2026-01-04 12:31:08','2026-01-04 12:31:08',2),(6,3,3,'오','2026-01-13 05:58:28','2026-01-13 05:58:28',NULL);
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `favorite_tracks`
--

DROP TABLE IF EXISTS `favorite_tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `favorite_tracks` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `track_id` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `favorite_tracks_user_id_foreign` (`user_id`),
  CONSTRAINT `favorite_tracks_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorite_tracks`
--

LOCK TABLES `favorite_tracks` WRITE;
/*!40000 ALTER TABLE `favorite_tracks` DISABLE KEYS */;
INSERT INTO `favorite_tracks` VALUES (10,10,'9W8sFGpCSek','like JENNIE','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/c4/9f/f1/c49ff171-59c6-6cc3-0576-9247f9b1e58b/dj.nmzxiamh.jpg/296x296bb.webp','youtube','2026-01-15 06:03:47','2026-01-15 06:03:47'),(12,10,'8UA3jTyZWYQ','Hype Boy','https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/4e/64/34/4e64344b-3ac6-c503-2c41-257a15401416/192641873096_Cover.jpg/600x600bb.jpg','youtube','2026-01-15 06:41:06','2026-01-15 06:41:06'),(14,10,'2','로파이(Lo-fi)스타일 르세라핌 리믹스','https://img.youtube.com/vi/Cs65y-9SMh4/mqdefault.jpg','remix','2026-01-15 06:49:32','2026-01-15 06:49:32'),(15,10,'3','JUMP (KSHMR & Ezra Hazard Remix)','https://img.youtube.com/vi/78iLfs2mYhY/mqdefault.jpg','remix','2026-01-15 06:49:44','2026-01-15 06:49:44'),(16,10,'1','어쿠스틱 스타일 Zero 리믹스','https://img.youtube.com/vi/iXUO2sR82BI/mqdefault.jpg','remix','2026-01-15 06:49:48','2026-01-15 06:49:48'),(17,10,'41','Mantra (edm)','https://img.youtube.com/vi/osNYssIep5w/mqdefault.jpg','remix','2026-01-15 06:59:35','2026-01-15 06:59:35'),(20,10,'42','Handlebars (Mixed)','https://img.youtube.com/vi/cyJdl-oBNE8/mqdefault.jpg','remix','2026-01-15 07:07:57','2026-01-15 07:07:57'),(22,9,'6','Like JENNIE (Peggy Gou Remix)','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/c4/9f/f1/c49ff171-59c6-6cc3-0576-9247f9b1e58b/dj.nmzxiamh.jpg/296x296bb.webp','remix','2026-01-15 13:06:34','2026-01-15 13:06:34'),(25,9,'mrV8kK5t0V8','Bruno Mars - I Just Might [Official Music Video]','https://i.ytimg.com/vi/mrV8kK5t0V8/hqdefault.jpg','youtube','2026-01-15 14:16:10','2026-01-15 14:16:10'),(28,9,'1','어쿠스틱 스타일 Zero 리믹스','https://img.youtube.com/vi/iXUO2sR82BI/mqdefault.jpg','remix','2026-01-15 15:01:45','2026-01-15 15:01:45'),(31,9,'lCp0BmcFPQ8','A$AP Rocky - Punk Rocky (Official Video)','https://i.ytimg.com/vi/lCp0BmcFPQ8/hqdefault.jpg','youtube','2026-01-15 17:01:48','2026-01-15 17:01:48'),(32,9,'19o3R_AVats','Fuerza Regida - Marlboro Rojo (Letra)','https://i.ytimg.com/vi/19o3R_AVats/hqdefault.jpg','youtube','2026-01-15 17:01:54','2026-01-15 17:01:54'),(33,9,'6s-nDXnISQU','Perfect Night','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/a0/cd/40/a0cd4013-89cf-0554-0aa5-1ac5a0bb3db1/196922680779_Cover.jpg/600x600bb.jpg','youtube','2026-01-16 04:19:17','2026-01-16 04:19:17'),(34,9,'4','JUMP (Weird Genius Remix)','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/00/3e/16/003e1619-3133-a934-3263-5749ee119625/8809519880736_cover.jpg/600x600bb.jpg','remix','2026-01-16 04:20:39','2026-01-16 04:20:39'),(35,9,'3','JUMP (KSHMR & Ezra Hazard Remix)',NULL,'remix','2026-01-16 07:21:04','2026-01-16 07:21:04'),(36,9,'13','Mantra (edm)','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/48/12/ac/4812acbe-515a-6c85-3dfe-5bcc7abb5f68/cover_KM0020451_1.jpg/600x600bb.jpg','remix','2026-01-16 08:58:22','2026-01-16 08:58:22'),(39,9,'40','Ditto(rnb)',NULL,'remix','2026-01-16 17:49:18','2026-01-16 17:49:18'),(40,9,'38','OMG(EDM)',NULL,'remix','2026-01-16 17:49:45','2026-01-16 17:49:45'),(41,3,'40','Ditto(rnb)',NULL,'remix','2026-01-16 17:57:33','2026-01-16 17:57:33'),(42,9,'42','JENNIE & Dua Lipa \'Handlebars (House Remix)\'','https://img.youtube.com/vi/cyJdl-oBNE8/mqdefault.jpg','remix','2026-01-16 18:05:05','2026-01-16 18:05:05'),(43,9,'9','Perfect Night','https://img.youtube.com/vi/6s-nDXnISQU/mqdefault.jpg','remix','2026-01-23 17:00:20','2026-01-23 17:00:20'),(45,9,'41','Mantra','https://img.youtube.com/vi/osNYssIep5w/mqdefault.jpg','remix','2026-01-23 17:29:25','2026-01-23 17:29:25');
/*!40000 ALTER TABLE `favorite_tracks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `genres`
--

DROP TABLE IF EXISTS `genres`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `genres` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `genres_slug_unique` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `genres`
--

LOCK TABLES `genres` WRITE;
/*!40000 ALTER TABLE `genres` DISABLE KEYS */;
INSERT INTO `genres` VALUES (1,'EDM','edm','2026-01-01 02:21:06','2026-01-01 02:21:06'),(2,'Lo-fi','lo-fi','2026-01-01 02:21:06','2026-01-01 02:21:06'),(3,'Hiphop','hiphop','2026-01-01 02:21:06','2026-01-01 02:21:06'),(5,'Phonk','phonk','2026-01-07 02:53:54','2026-01-07 02:53:54'),(6,'City Pop','city-pop','2026-01-07 02:53:54','2026-01-07 02:53:54'),(7,'R&B','r-n-b','2026-01-07 02:53:54','2026-01-07 02:53:54'),(9,'Hyperpop','hyperpop','2026-01-07 02:53:54','2026-01-07 02:53:54'),(10,'Rock/Metal','rock-metal','2026-01-07 02:53:54','2026-01-07 02:53:54'),(11,'Acoustic','acoustic','2026-01-07 02:53:54','2026-01-07 02:53:54'),(12,'Sped Up','sped-up','2026-01-07 02:53:54','2026-01-07 02:53:54');
/*!40000 ALTER TABLE `genres` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hot_charts`
--

DROP TABLE IF EXISTS `hot_charts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `hot_charts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `platform` varchar(255) NOT NULL,
  `rank` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `artist` varchar(255) NOT NULL,
  `external_url` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hot_charts`
--

LOCK TABLES `hot_charts` WRITE;
/*!40000 ALTER TABLE `hot_charts` DISABLE KEYS */;
/*!40000 ALTER TABLE `hot_charts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) unsigned NOT NULL,
  `reserved_at` int(10) unsigned DEFAULT NULL,
  `available_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `likes`
--

DROP TABLE IF EXISTS `likes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `likes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `post_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `likes_user_id_post_id_unique` (`user_id`,`post_id`),
  KEY `likes_post_id_foreign` (`post_id`),
  CONSTRAINT `likes_post_id_foreign` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `likes_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `likes`
--

LOCK TABLES `likes` WRITE;
/*!40000 ALTER TABLE `likes` DISABLE KEYS */;
INSERT INTO `likes` VALUES (16,2,3,'2026-01-04 14:43:50','2026-01-04 14:43:50'),(20,2,2,'2026-01-05 08:16:23','2026-01-05 08:16:23'),(22,3,3,'2026-01-05 13:23:33','2026-01-05 13:23:33'),(23,3,2,'2026-01-06 16:34:29','2026-01-06 16:34:29'),(24,7,6,'2026-01-11 12:24:42','2026-01-11 12:24:42');
/*!40000 ALTER TABLE `likes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `match_logs`
--

DROP TABLE IF EXISTS `match_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `match_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `winner_id` bigint(20) unsigned NOT NULL,
  `loser_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `match_logs_winner_id_foreign` (`winner_id`),
  KEY `match_logs_loser_id_foreign` (`loser_id`),
  KEY `match_logs_user_id_foreign` (`user_id`),
  CONSTRAINT `match_logs_loser_id_foreign` FOREIGN KEY (`loser_id`) REFERENCES `remixes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `match_logs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `match_logs_winner_id_foreign` FOREIGN KEY (`winner_id`) REFERENCES `remixes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `match_logs`
--

LOCK TABLES `match_logs` WRITE;
/*!40000 ALTER TABLE `match_logs` DISABLE KEYS */;
INSERT INTO `match_logs` VALUES (1,6,33,3,'2026-01-13 12:45:54','2026-01-13 12:45:54'),(2,6,32,3,'2026-01-13 12:46:03','2026-01-13 12:46:03'),(3,6,18,3,'2026-01-13 12:59:44','2026-01-13 12:59:44'),(4,6,39,3,'2026-01-13 12:59:51','2026-01-13 12:59:51'),(5,34,31,10,'2026-01-14 14:41:25','2026-01-14 14:41:25'),(6,13,24,10,'2026-01-14 14:41:27','2026-01-14 14:41:27'),(7,43,7,10,'2026-01-14 14:41:33','2026-01-14 14:41:33'),(8,42,31,10,'2026-01-15 07:07:58','2026-01-15 07:07:58'),(9,42,16,9,'2026-01-15 15:37:10','2026-01-15 15:37:10'),(10,42,23,9,'2026-01-15 15:59:10','2026-01-15 15:59:10'),(11,25,10,9,'2026-01-16 16:23:19','2026-01-16 16:23:19'),(12,7,29,3,'2026-01-16 17:53:12','2026-01-16 17:53:12'),(13,31,29,3,'2026-01-16 17:53:23','2026-01-16 17:53:23'),(14,30,22,3,'2026-01-16 17:53:55','2026-01-16 17:53:55'),(15,22,21,9,'2026-01-20 03:47:54','2026-01-20 03:47:54'),(16,31,8,9,'2026-01-20 03:47:57','2026-01-20 03:47:57'),(17,30,21,9,'2026-01-20 03:47:58','2026-01-20 03:47:58'),(18,34,8,9,'2026-01-20 03:48:00','2026-01-20 03:48:00'),(19,25,9,9,'2026-01-20 03:48:02','2026-01-20 03:48:02'),(20,38,29,9,'2026-01-23 16:58:47','2026-01-23 16:58:47'),(21,11,30,9,'2026-01-23 16:58:49','2026-01-23 16:58:49'),(22,1,35,9,'2026-01-23 16:58:52','2026-01-23 16:58:52'),(23,22,8,9,'2026-01-23 16:58:54','2026-01-23 16:58:54'),(24,21,28,9,'2026-01-23 16:58:57','2026-01-23 16:58:57'),(25,13,34,9,'2026-01-23 16:58:58','2026-01-23 16:58:58'),(26,7,18,9,'2026-01-23 16:59:00','2026-01-23 16:59:00'),(27,10,23,9,'2026-01-23 16:59:01','2026-01-23 16:59:01'),(28,6,27,9,'2026-01-23 16:59:03','2026-01-23 16:59:03'),(29,25,43,9,'2026-01-23 16:59:04','2026-01-23 16:59:04'),(30,8,24,9,'2026-01-23 16:59:05','2026-01-23 16:59:05'),(31,15,6,9,'2026-01-23 16:59:07','2026-01-23 16:59:07'),(32,41,1,9,'2026-01-23 16:59:08','2026-01-23 16:59:08'),(33,19,31,9,'2026-01-23 16:59:10','2026-01-23 16:59:10'),(34,12,37,9,'2026-01-23 17:03:50','2026-01-23 17:03:50'),(35,42,11,9,'2026-01-23 17:04:08','2026-01-23 17:04:08');
/*!40000 ALTER TABLE `match_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2025_12_25_000000_create_genres_table',1),(5,'2025_12_25_012348_create_personal_access_tokens_table',1),(6,'2025_12_25_142323_create_worldcups_table',1),(7,'2025_12_25_142324_create_music_tracks_table',1),(8,'2025_12_25_142324_create_remixes_table',1),(9,'2025_12_25_142324_create_votes_table',1),(10,'2025_12_25_142324_create_worldcup_items_table',1),(11,'2025_12_25_142325_create_hot_charts_table',1),(13,'2025_12_25_142325_create_posts_table',2),(14,'2026_01_02_122942_add_columns_to_posts_table',3),(15,'2026_01_03_132558_create_comments_table',4),(16,'2026_01_04_085445_add_parent_id_to_comments_table',5),(17,'2026_01_04_140823_create_likes_table',6),(18,'2026_01_07_164529_add_track_info_to_remixes_table',7),(19,'2026_01_08_040201_modify_music_track_id_in_remixes_table',8),(20,'2026_01_08_075846_create_trends_table',9),(22,'2026_01_11_105827_add_remix_id_to_posts_table',10),(23,'2026_01_13_075601_create_match_logs_table',11),(24,'2026_01_13_135911_add_google_id_to_users_table',12),(25,'2026_01_14_140418_add_kakao_id_to_users_table',13),(26,'2026_01_14_153340_create_favorite_tracks_table',14),(27,'2026_01_16_043917_add_artist_fields_to_users_table',15),(28,'2026_01_16_055925_add_public_email_to_users_table',16),(29,'2026_01_16_061416_create_point_histories_table',17),(30,'2026_01_16_063348_add_profile_photo_path_to_users_table',18),(31,'2026_01_20_035423_add_admin_and_active_flags_to_users_table',19),(32,'2026_01_22_045113_add_is_active_to_remixes_table',20);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `music_tracks`
--

DROP TABLE IF EXISTS `music_tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `music_tracks` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `artist` varchar(255) NOT NULL,
  `thumbnail_url` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `music_tracks`
--

LOCK TABLES `music_tracks` WRITE;
/*!40000 ALTER TABLE `music_tracks` DISABLE KEYS */;
INSERT INTO `music_tracks` VALUES (1,'Zero','NewJeans','https://example.com/thumb1.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(2,'Perfect Night','LE SSERAFIM','https://example.com/thumb2.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(3,'JUMP','BLACKPINK','https://example.com/thumb3.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(4,'Like JENNIE','Jennie','https://example.com/thumb3.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(5,'Hype Boy','NewJeans','https://example.com/thumb1.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(6,'Attention','NewJeans','https://example.com/thumb1.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(7,'Mantra','Jennie','https://example.com/thumb1.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(8,'SuperShy','NewJeans','https://example.com/thumb1.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(9,'ANTIFRAGILE','LE SSERAFIM','https://example.com/thumb2.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(10,'OMG','NewJeans','https://example.com/thumb1.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(11,'Ditto','NewJeans','https://example.com/thumb2.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(12,'Drama','aespa','https://example.com/thumb2.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(13,'Seven','Jungkook','https://example.com/thumb2.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(14,'Magnetic','ILLIT','https://example.com/thumb2.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(15,'Love Lee','AKMU','https://example.com/thumb2.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(16,'After LIKE','IVE','https://example.com/thumb2.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(17,'Sticky','KISS OF LIFE','https://example.com/thumb2.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06'),(18,'Supernatural','NewJeans','https://example.com/thumb2.jpg','2026-01-01 02:21:06','2026-01-01 02:21:06');
/*!40000 ALTER TABLE `music_tracks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
INSERT INTO `password_reset_tokens` VALUES ('lee@gmail.com','$2y$12$CZjISSKsiafNzEx/7lvmUuzESDWN5L4mR8oAYTIX0h4hWtxGajhxW','2026-01-01 23:51:32');
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) unsigned NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `point_histories`
--

DROP TABLE IF EXISTS `point_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `point_histories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `amount` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `pointable_type` varchar(255) NOT NULL,
  `pointable_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `point_histories_user_id_foreign` (`user_id`),
  KEY `point_histories_pointable_type_pointable_id_index` (`pointable_type`,`pointable_id`),
  CONSTRAINT `point_histories_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `point_histories`
--

LOCK TABLES `point_histories` WRITE;
/*!40000 ALTER TABLE `point_histories` DISABLE KEYS */;
/*!40000 ALTER TABLE `point_histories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `posts`
--

DROP TABLE IF EXISTS `posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `posts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `view_count` int(11) NOT NULL DEFAULT 0,
  `category` varchar(255) NOT NULL DEFAULT 'general',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `remix_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `posts_user_id_foreign` (`user_id`),
  KEY `posts_remix_id_foreign` (`remix_id`),
  CONSTRAINT `posts_remix_id_foreign` FOREIGN KEY (`remix_id`) REFERENCES `remixes` (`id`) ON DELETE SET NULL,
  CONSTRAINT `posts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `posts`
--

LOCK TABLES `posts` WRITE;
/*!40000 ALTER TABLE `posts` DISABLE KEYS */;
INSERT INTO `posts` VALUES (1,2,'애플뮤직좋아요??','스포티파이 보다 좋나요??',83,'question','2026-01-02 14:17:29','2026-01-11 16:57:55',NULL),(2,9,'EDM 리믹스 추천합니다.','아주 좋아요',88,'recommend','2026-01-03 12:26:51','2026-01-16 16:50:49',13),(3,2,'뉴진스 하니 어도어 복귀','<img src=\"http://localhost/storage/uploads/lleypXJSyDJw1DSj0ef8Hc6OqNXzfpBllvlB5qbn.png\"><p></p>',51,'general','2026-01-04 13:18:27','2026-01-13 05:58:28',NULL),(4,3,'안녕하세요','<p>안녕하세요!!</p>',10,'general','2026-01-06 16:27:43','2026-01-13 05:58:10',NULL),(6,3,'Like JENNIE 리믹스 강추','<p>한번들어보세요 좋네욥</p>',23,'recommend','2026-01-11 11:36:17','2026-01-23 14:28:23',6),(7,7,'강추입니다.','<p>들어보시죠 ^0^</p><p></p>',34,'recommend','2026-01-11 12:22:37','2026-01-23 14:04:21',4);
/*!40000 ALTER TABLE `posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `remixes`
--

DROP TABLE IF EXISTS `remixes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `remixes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `track_title` varchar(255) DEFAULT NULL,
  `artist_name` varchar(255) DEFAULT NULL,
  `album_cover_url` varchar(255) DEFAULT NULL,
  `itunes_track_id` varchar(255) DEFAULT NULL,
  `music_track_id` bigint(20) unsigned DEFAULT NULL,
  `genre_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `youtube_url` varchar(255) NOT NULL,
  `youtube_video_id` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `view_count` int(10) unsigned NOT NULL DEFAULT 0,
  `vote_count` int(10) unsigned NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `remixes_music_track_id_foreign` (`music_track_id`),
  KEY `remixes_genre_id_foreign` (`genre_id`),
  CONSTRAINT `remixes_genre_id_foreign` FOREIGN KEY (`genre_id`) REFERENCES `genres` (`id`) ON DELETE CASCADE,
  CONSTRAINT `remixes_music_track_id_foreign` FOREIGN KEY (`music_track_id`) REFERENCES `music_tracks` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `remixes`
--

LOCK TABLES `remixes` WRITE;
/*!40000 ALTER TABLE `remixes` DISABLE KEYS */;
INSERT INTO `remixes` VALUES (1,'Zero','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/6c/5a/04/6c5a04e7-436d-d4d5-bf7e-fdd01d033eb9/196922401121_Cover.jpg/600x600bb.jpg','1678545886',1,11,6,'어쿠스틱 스타일 Zero 리믹스','https://www.youtube.com/watch?v=iXUO2sR82BI','iXUO2sR82BI',NULL,150,14,1,'2026-01-01 02:21:06','2026-01-23 16:58:52'),(2,'Perfect Night','르세라핌','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/a0/cd/40/a0cd4013-89cf-0554-0aa5-1ac5a0bb3db1/196922680779_Cover.jpg/600x600bb.jpg','1712731159',2,2,2,'로파이(Lo-fi)스타일 르세라핌 리믹스','https://www.youtube.com/watch?v=Cs65y-9SMh4','Cs65y-9SMh4',NULL,2400,7,1,'2026-01-01 02:21:06','2026-01-07 02:26:24'),(3,'뛰어(JUMP)','BLACKPINK','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/00/3e/16/003e1619-3133-a934-3263-5749ee119625/8809519880736_cover.jpg/600x600bb.jpg','1825258504',3,1,5,'JUMP (KSHMR & Ezra Hazard Remix)','https://www.youtube.com/watch?v=78iLfs2mYhY','78iLfs2mYhY',NULL,890,15,1,'2026-01-01 02:21:06','2026-01-12 07:20:07'),(4,'뛰어(JUMP)','BLACKPINK','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/00/3e/16/003e1619-3133-a934-3263-5749ee119625/8809519880736_cover.jpg/600x600bb.jpg','1825258504',3,1,5,'JUMP (Weird Genius Remix)','https://www.youtube.com/watch?v=C5hg0DkO-BM','C5hg0DkO-BM',NULL,12,3,1,'2026-01-01 02:21:06','2026-01-11 15:27:42'),(6,'like JENNIE','JENNIE','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/c4/9f/f1/c49ff171-59c6-6cc3-0576-9247f9b1e58b/dj.nmzxiamh.jpg/296x296bb.webp',NULL,4,1,5,'Like JENNIE (Peggy Gou Remix)','https://www.youtube.com/watch?v=YQwTOpvcTYU','YQwTOpvcTYU',NULL,12,10,1,'2026-01-01 02:21:06','2026-01-23 16:59:03'),(7,'like JENNIE','JENNIE','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/c4/9f/f1/c49ff171-59c6-6cc3-0576-9247f9b1e58b/dj.nmzxiamh.jpg/296x296bb.webp',NULL,4,1,5,'Like Jennie (Whisnu Santika, Rey Putra, Akeey Edit)','https://www.youtube.com/watch?v=9W8sFGpCSek','9W8sFGpCSek',NULL,12,5,1,'2026-01-01 02:21:06','2026-01-23 16:59:00'),(8,'Hype Boy','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/4e/64/34/4e64344b-3ac6-c503-2c41-257a15401416/192641873096_Cover.jpg/600x600bb.jpg','1635469851',5,7,8,'Hype Boy (r&b 리믹스)','https://www.youtube.com/watch?v=8UA3jTyZWYQ','8UA3jTyZWYQ',NULL,1,4,1,'2026-01-01 02:21:06','2026-01-23 16:59:05'),(9,'Perfect Night','르세라핌','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/a0/cd/40/a0cd4013-89cf-0554-0aa5-1ac5a0bb3db1/196922680779_Cover.jpg/600x600bb.jpg','1712731159',2,6,2,'perfrct night (city pop) ','https://www.youtube.com/watch?v=6s-nDXnISQU','6s-nDXnISQU',NULL,1,0,1,'2026-01-01 02:21:06','2026-01-01 02:21:06'),(10,'Hype Boy','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/00/3e/16/003e1619-3133-a934-3263-5749ee119625/8809519880736_cover.jpg/600x600bb.jpg','1635469851',5,6,8,'하입보이 (city pop) ','https://www.youtube.com/watch?v=AEl6PCx0iCA','AEl6PCx0iCA',NULL,1,2,1,'2026-01-01 02:21:06','2026-01-23 16:59:01'),(11,'Attention','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/4e/64/34/4e64344b-3ac6-c503-2c41-257a15401416/192641873096_Cover.jpg/600x600bb.jpg','1635469694',6,7,8,'Attention (rnb) ','https://www.youtube.com/watch?v=h3lMOn0ltK8','h3lMOn0ltK8',NULL,1,4,1,'2026-01-01 02:21:06','2026-01-23 16:58:49'),(12,'Attention','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/4e/64/34/4e64344b-3ac6-c503-2c41-257a15401416/192641873096_Cover.jpg/600x600bb.jpg','1635469694',6,6,8,'Attention (city pop)','https://www.youtube.com/watch?v=hgIWQHQl_nU','hgIWQHQl_nU',NULL,1,5,1,'2026-01-01 02:21:06','2026-01-23 17:03:50'),(13,'Mantra','제니','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/48/12/ac/4812acbe-515a-6c85-3dfe-5bcc7abb5f68/cover_KM0020451_1.jpg/600x600bb.jpg','1773211923',7,1,4,'Mantra (edm)','https://www.youtube.com/watch?v=aDAx5C6Dlao','aDAx5C6Dlao',NULL,1,2,1,'2026-01-01 02:21:06','2026-01-23 16:58:58'),(15,'Super Shy','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/63/e5/e2/63e5e2e4-829b-924d-a1dc-8058a1d69bd4/196922462702_Cover.jpg/600x600bb.jpg',NULL,8,9,8,'super shy  (Hyper Pop)','https://www.youtube.com/watch?v=C8Uix3JLM6Q','C8Uix3JLM6Q',NULL,0,2,1,'2026-01-01 02:21:06','2026-01-23 16:59:07'),(16,'Super Shy','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/63/e5/e2/63e5e2e4-829b-924d-a1dc-8058a1d69bd4/196922462702_Cover.jpg/600x600bb.jpg','1692686518',8,7,8,'super shy (rnb)','https://www.youtube.com/watch?v=fLbapP9JXEI','fLbapP9JXEI',NULL,0,3,1,'2026-01-01 02:21:06','2026-01-13 12:45:54'),(17,'like JENNIE','JENNIE','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/c4/9f/f1/c49ff171-59c6-6cc3-0576-9247f9b1e58b/dj.nmzxiamh.jpg/296x296bb.webp',NULL,4,1,3,'Like Jennie(edm)','https://www.youtube.com/watch?v=_ptRlhv8XoY','_ptRlhv8XoY',NULL,0,3,1,'2026-01-01 02:21:06','2026-01-13 07:49:50'),(18,'ANTIFRAGILE','르세라핌','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/c8/79/da/c879dadf-db1e-95a5-caf5-b18c7c81d2b6/192641874413_Cover.jpg/600x600bb.jpg','1647830390',9,1,4,'ANTIFRAGILE (edm)','https://www.youtube.com/watch?v=UOXfU0g42Vg','UOXfU0g42Vg',NULL,0,1,1,'2026-01-01 02:21:06','2026-01-11 15:26:53'),(19,'OMG','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music113/v4/48/96/08/4896085e-b550-cb0a-3e5b-1f203521cb82/196922265464_Cover.jpg/600x600bb.jpg','1659513445',10,1,8,'OMG (edm)','https://www.youtube.com/watch?v=38qmk7KyG9s','38qmk7KyG9s',NULL,0,2,1,'2026-01-01 02:21:06','2026-01-23 16:59:10'),(20,'Magnetic','아일릿','https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/3e/49/1e/3e491e43-4961-21ab-2abe-37fb1c0feb40/196922879227_Cover.jpg/600x600bb.jpg','1734500896',14,6,7,'Magnetic (city pop)','https://www.youtube.com/watch?v=BjgQ0uuz-JM','BjgQ0uuz-JM',NULL,0,0,1,'2026-01-01 02:21:06','2026-01-01 02:21:06'),(21,'Magnetic','아일릿','https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/3e/49/1e/3e491e43-4961-21ab-2abe-37fb1c0feb40/196922879227_Cover.jpg/600x600bb.jpg','1734500896',14,7,7,'Magnetic (rnb)','https://www.youtube.com/watch?v=7naXJ6n4eKQ','7naXJ6n4eKQ',NULL,0,1,1,'2026-01-01 02:21:06','2026-01-23 16:58:57'),(22,'Ditto','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/f6/29/42/f629426e-92fe-535c-cbe4-76e70850819b/196922287107_Cover.jpg/600x600bb.jpg','1734500896\n1657231962',11,6,8,'Ditto (city pop) ','https://www.youtube.com/watch?v=BT5b9NSpQCY','BT5b9NSpQCY',NULL,0,4,1,'2026-01-01 02:21:06','2026-01-23 16:58:54'),(23,'Drama','aespa','https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/f7/f0/5c/f7f05ce4-e5a4-900d-e087-1dd9668b2b34/888735945939.jpg/600x600bb.jpg','1715939931',12,5,7,'Drama (phonk) ','https://www.youtube.com/watch?v=W7iF-kkXaAc','W7iF-kkXaAc',NULL,0,1,1,'2026-01-01 02:21:06','2026-01-13 12:59:51'),(24,'Drama','aespa','https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/f7/f0/5c/f7f05ce4-e5a4-900d-e087-1dd9668b2b34/888735945939.jpg/600x600bb.jpg','1715939931',12,1,7,'Drama (rnb) ','https://www.youtube.com/watch?v=5zkDEJp29Y0','5zkDEJp29Y0',NULL,0,0,1,'2026-01-01 02:21:06','2026-01-01 02:21:06'),(25,'Supernatural','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/ab/ce/d6/abced6f6-2b90-c230-eb4b-e146734a3a22/196922907821_Cover.jpg/600x600bb.jpg','1750576834',18,7,8,'Supernatural (rnb)','https://www.youtube.com/watch?v=NOCti4PK4Ho','NOCti4PK4Ho',NULL,0,4,1,'2026-01-01 02:21:06','2026-01-23 16:59:04'),(26,'Seven','정국 & Latto','https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/a5/a6/56/a5a6561a-f570-2fb1-5a3a-95b150c18f18/196922550928_Cover.jpg/60x60bb.jpg','1697147752',13,2,7,'Seven (Lo-fi) ','https://www.youtube.com/watch?v=wvL3Nl25evg','wvL3Nl25evg',NULL,0,0,1,'2026-01-01 02:21:06','2026-01-01 02:21:06'),(27,'Seven','정국 & Latto','https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/a5/a6/56/a5a6561a-f570-2fb1-5a3a-95b150c18f18/196922550928_Cover.jpg/60x60bb.jpg','1697147752',13,1,7,'Seven (EDM) ','https://www.youtube.com/watch?v=o6Q-PC7dRaE','o6Q-PC7dRaE',NULL,0,1,1,'2026-01-01 02:21:06','2026-01-11 15:48:06'),(28,'After LIKE','아이브','https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/f0/5f/11/f05f1119-8992-ba35-1e97-20213a637870/cover_KM0015998_1.jpg/600x600bb.jpg','1640202552',16,1,7,'After LIKE (edm) ','https://www.youtube.com/watch?v=vXFkkHuuD6c','vXFkkHuuD6c',NULL,0,2,1,NULL,'2026-01-12 07:32:04'),(29,'Sticky','KISS OF LIFE','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/02/82/4f/02824f79-2fec-d40e-076f-b20803bebe0c/8809484117899_Cover.jpg/600x600bb.jpg','1753900853',16,7,7,'Sticky (rnb)','https://www.youtube.com/watch?v=JJ6m29tlDrs','JJ6m29tlDrs',NULL,0,0,1,NULL,NULL),(30,'Hype Boy','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/4e/64/34/4e64344b-3ac6-c503-2c41-257a15401416/192641873096_Cover.jpg/600x600bb.jpg','1635469851',NULL,7,3,'Hype Boy(rnb)','https://www.youtube.com/watch?v=8UA3jTyZWYQ&list=RDo73ZjoYVKzk&index=2','8UA3jTyZWYQ','TEST',0,3,1,'2026-01-08 04:03:49','2026-01-20 03:47:58'),(31,'How Sweet','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/bf/68/ca/bf68ca64-4acd-543f-bc78-455f11f06105/196922889738_Cover.jpg/600x600bb.jpg','1744448416',NULL,7,3,'How Sweet(rnb)','https://www.youtube.com/watch?v=o73ZjoYVKzk&list=RDo73ZjoYVKzk&index=1','o73ZjoYVKzk','TEST',0,2,1,'2026-01-08 04:08:38','2026-01-20 03:47:57'),(32,'Perfect Night','르세라핌','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/a0/cd/40/a0cd4013-89cf-0554-0aa5-1ac5a0bb3db1/196922680779_Cover.jpg/600x600bb.jpg','1712731159',NULL,7,3,'Perfect Night(rnb)','https://www.youtube.com/watch?v=GU_dwF0apoI&list=RDGU_dwF0apoI&start_radio=1','GU_dwF0apoI',NULL,0,0,1,'2026-01-08 07:13:27','2026-01-08 07:13:27'),(33,'뛰어(JUMP)','BLACKPINK','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/00/3e/16/003e1619-3133-a934-3263-5749ee119625/8809519880736_cover.jpg/600x600bb.jpg','1825258504',NULL,7,3,'BLACKPINK - JUMP(rnb)','https://www.youtube.com/watch?v=ybajjaQ7ojc&list=RDybajjaQ7ojc&start_radio=1','ybajjaQ7ojc',NULL,0,1,1,'2026-01-08 07:14:57','2026-01-11 15:26:21'),(34,'Attention','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/4e/64/34/4e64344b-3ac6-c503-2c41-257a15401416/192641873096_Cover.jpg/600x600bb.jpg','1635469694',NULL,7,3,'Attention(rnb)','https://www.youtube.com/watch?v=O2AhOp43FMc&list=RDO2AhOp43FMc&start_radio=1','O2AhOp43FMc',NULL,0,3,1,'2026-01-08 07:32:07','2026-01-20 03:48:00'),(35,'Mantra','제니','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/48/12/ac/4812acbe-515a-6c85-3dfe-5bcc7abb5f68/cover_KM0020451_1.jpg/600x600bb.jpg','1773211923',NULL,12,3,'Mantra(Sped up)','https://www.youtube.com/watch?v=xdSOhjrc2Vw&list=RDxdSOhjrc2Vw&start_radio=1','xdSOhjrc2Vw',NULL,0,1,1,'2026-01-08 07:37:07','2026-01-11 15:27:09'),(36,'Super Shy','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/63/e5/e2/63e5e2e4-829b-924d-a1dc-8058a1d69bd4/196922462702_Cover.jpg/600x600bb.jpg','1692686518',NULL,7,3,'Super Shy (R&B)','https://www.youtube.com/watch?v=eSNg42NoGII&list=RDeSNg42NoGII&start_radio=1','eSNg42NoGII',NULL,0,0,1,'2026-01-08 07:38:44','2026-01-08 07:38:44'),(37,'ANTIFRAGILE','르세라핌','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/c8/79/da/c879dadf-db1e-95a5-caf5-b18c7c81d2b6/192641874413_Cover.jpg/600x600bb.jpg','1647830390',NULL,10,3,'ANTIFRAGILE(ROCK)','https://www.youtube.com/watch?v=cj55umtdaDk&list=RDcj55umtdaDk&start_radio=1','cj55umtdaDk',NULL,0,0,1,'2026-01-08 07:42:09','2026-01-08 07:42:09'),(38,'OMG','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music113/v4/48/96/08/4896085e-b550-cb0a-3e5b-1f203521cb82/196922265464_Cover.jpg/600x600bb.jpg','1659513445',NULL,1,9,'OMG(EDM)','https://www.youtube.com/watch?v=tu96HWfQVrE&list=RDtu96HWfQVrE&start_radio=1','tu96HWfQVrE',NULL,0,4,1,'2026-01-08 07:43:33','2026-01-23 16:58:47'),(39,'Magnetic','아일릿','https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/3e/49/1e/3e491e43-4961-21ab-2abe-37fb1c0feb40/196922879227_Cover.jpg/600x600bb.jpg','1734500896',NULL,1,3,'Magnetic(edm)','https://www.youtube.com/watch?v=L9nHQefuPw4&list=RDL9nHQefuPw4&start_radio=1','L9nHQefuPw4',NULL,0,0,1,'2026-01-08 07:44:13','2026-01-08 07:44:13'),(40,'Ditto','뉴진스','https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/f6/29/42/f629426e-92fe-535c-cbe4-76e70850819b/196922287107_Cover.jpg/600x600bb.jpg','1657231962',NULL,7,9,'Ditto(rnb)','https://www.youtube.com/watch?v=defsrAtJbx0&list=RDdefsrAtJbx0&start_radio=1','defsrAtJbx0',NULL,0,2,1,'2026-01-08 07:44:47','2026-01-11 15:24:35'),(41,'Mantra','제니','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/48/12/ac/4812acbe-515a-6c85-3dfe-5bcc7abb5f68/cover_KM0020451_1.jpg/600x600bb.jpg','1773211923',7,1,4,'Mantra (edm)','https://www.youtube.com/watch?v=osNYssIep5w','osNYssIep5w',NULL,1,5,1,'2026-01-01 02:21:06','2026-01-23 16:59:08'),(42,'Handlebars (Mixed)','제니 & Dua Lipa','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/be/b9/09/beb9094f-d3ee-1b36-08e1-87affe531c92/f004797e-ec95-4d55-a13f-884ac32aaf36.png/600x600bb.jpg','1818167958',NULL,1,3,'JENNIE & Dua Lipa \'Handlebars (House Remix)\'','https://www.youtube.com/watch?v=cyJdl-oBNE8&list=RDcyJdl-oBNE8&start_radio=1','cyJdl-oBNE8',NULL,0,5,1,'2026-01-12 07:17:57','2026-01-23 17:04:08'),(43,'FLOWER','지수','https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/c0/13/d1/c013d179-4cc3-0f48-e3e8-7b977e38dc0c/JISOO_Digital_Cover_4000px.jpg/600x600bb.jpg','1678664649',NULL,11,5,'지수 - 꽃 리믹스','https://www.youtube.com/watch?v=lTZK8Vhy6V4&list=RDlTZK8Vhy6V4&start_radio=1','lTZK8Vhy6V4',NULL,0,2,1,'2026-01-12 07:29:21','2026-01-14 14:41:33');
/*!40000 ALTER TABLE `remixes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('co5vIkJB0loU54FJJgjK1prIIRhYcYHnowmbpS3h',9,'192.168.65.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','YTo1OntzOjY6Il90b2tlbiI7czo0MDoiY292RE45Rk9CQ3JxSHFVdWVXOXRoR1k2ZHE3cTlBdzc1cEVidWVKaSI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjUxOiJodHRwOi8vbG9jYWxob3N0L3JlbWl4ZXM/Z2VucmU9JnNvcnQ9cG9wdWxhciZ0cmFjaz0iO3M6NToicm91dGUiO3M6MTM6InJlbWl4ZXMuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX1zOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7aTo5O30=',1769189623);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trends`
--

DROP TABLE IF EXISTS `trends`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `trends` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `platform` varchar(255) NOT NULL,
  `category` varchar(255) NOT NULL,
  `rank` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `artist` varchar(255) NOT NULL,
  `album_cover_url` varchar(255) DEFAULT NULL,
  `external_id` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `trends_platform_category_index` (`platform`,`category`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trends`
--

LOCK TABLES `trends` WRITE;
/*!40000 ALTER TABLE `trends` DISABLE KEYS */;
INSERT INTO `trends` VALUES (21,'youtube','kr_songs',1,'Wish','Wonpil (DAY6) - Topic','https://i.ytimg.com/vi/4Mftjtzee9w/hqdefault.jpg','4Mftjtzee9w','2026-01-08 15:20:57','2026-01-13 13:41:51'),(22,'youtube','kr_songs',2,'I Just Might','Bruno Mars - Topic','https://i.ytimg.com/vi/luotSpkyCVU/hqdefault.jpg','luotSpkyCVU','2026-01-08 15:20:57','2026-01-13 13:41:51'),(23,'youtube','kr_songs',3,'Golden (Glowin\' Version)','HUNTR/X - Topic','https://i.ytimg.com/vi/a7DtlXpUj4I/hqdefault.jpg','a7DtlXpUj4I','2026-01-08 15:20:57','2026-01-13 13:41:51'),(24,'youtube','kr_songs',4,'LIE (2026 ver.)','Ha Yea Song - Topic','https://i.ytimg.com/vi/dXslk1nJLOM/hqdefault.jpg','dXslk1nJLOM','2026-01-08 15:20:57','2026-01-13 13:41:51'),(25,'youtube','kr_songs',5,'AIZO','King Gnu - Topic','https://i.ytimg.com/vi/wQiz17AKhjM/hqdefault.jpg','wQiz17AKhjM','2026-01-08 15:20:57','2026-01-13 13:41:51'),(26,'youtube','kr_songs',6,'Love Me More','Apink - Topic','https://i.ytimg.com/vi/BnqvaC65vvM/hqdefault.jpg','BnqvaC65vvM','2026-01-08 15:20:57','2026-01-13 13:41:51'),(27,'youtube','kr_songs',7,'Blue','DxS (SEVENTEEN) - Topic','https://i.ytimg.com/vi/l2HfBaZi-4k/hqdefault.jpg','l2HfBaZi-4k','2026-01-08 15:20:57','2026-01-13 13:41:51'),(28,'youtube','kr_songs',8,'Not Like a Movie','H1-KEY - Topic','https://i.ytimg.com/vi/_UiZ-Uuw1ro/hqdefault.jpg','_UiZ-Uuw1ro','2026-01-08 15:20:57','2026-01-13 13:41:51'),(29,'youtube','kr_songs',9,'Every Moment Of You (Original)','Sung Si-kyung - Topic','https://i.ytimg.com/vi/izssDYTMXis/hqdefault.jpg','izssDYTMXis','2026-01-08 15:20:57','2026-01-13 13:41:51'),(30,'youtube','kr_songs',10,'Guilt','Min Kyung Hoon - Topic','https://i.ytimg.com/vi/9GLRB9BO92g/hqdefault.jpg','9GLRB9BO92g','2026-01-08 15:20:57','2026-01-13 13:41:51'),(31,'youtube','kr_trend',1,'Blue','DxS (SEVENTEEN) - Topic','https://i.ytimg.com/vi/l2HfBaZi-4k/hqdefault.jpg','l2HfBaZi-4k','2026-01-08 15:20:57','2026-01-13 13:41:52'),(32,'youtube','kr_trend',2,'레이디 두아 | 공식 티저 예고편 | 넷플릭스','Netflix Korea 넷플릭스 코리아','https://i.ytimg.com/vi/IPn4svVIR68/hqdefault.jpg','IPn4svVIR68','2026-01-08 15:20:57','2026-01-13 13:41:52'),(33,'youtube','kr_trend',3,'[LIVE] 1월 13일 아이온2 업데이트 프리뷰 방송','AION2','https://i.ytimg.com/vi/zEQoiHYMhaE/hqdefault.jpg','zEQoiHYMhaE','2026-01-08 15:20:57','2026-01-13 13:41:52'),(34,'youtube','kr_trend',4,'도겸X승관 (SEVENTEEN) \'Blue\' Official MV (Cinema Ver.)','HYBE LABELS','https://i.ytimg.com/vi/N9X1o0q4aIc/hqdefault.jpg','N9X1o0q4aIc','2026-01-08 15:20:57','2026-01-13 13:41:52'),(35,'youtube','kr_trend',5,'와.. 닥터 둠의 충격적인 모든 정복자 캉 학살ㄷㄷ ≪어벤져스: 둠스데이≫ 공식 예고편 루머 총정리','무비띵크_Movie Think','https://i.ytimg.com/vi/M8uoJlDRxZo/hqdefault.jpg','M8uoJlDRxZo','2026-01-08 15:20:57','2026-01-13 13:41:52'),(36,'youtube','kr_trend',6,'[마비노기 모바일] 캠파 LIVE | 26.01.13','마비노기 모바일','https://i.ytimg.com/vi/a4cdEyloeh0/hqdefault.jpg','a4cdEyloeh0','2026-01-08 15:20:57','2026-01-13 13:41:52'),(37,'youtube','kr_trend',7,'lulu.','Mrs. GREEN APPLE - Topic','https://i.ytimg.com/vi/4REuyY89tfw/hqdefault.jpg','4REuyY89tfw','2026-01-08 15:20:57','2026-01-13 13:41:52'),(38,'youtube','kr_trend',8,'원딜을 다시 위대하게','괴물쥐 유튜브','https://i.ytimg.com/vi/flGaTkZ7Ryg/hqdefault.jpg','flGaTkZ7Ryg','2026-01-08 15:20:57','2026-01-13 13:41:52'),(39,'youtube','kr_trend',9,'[MV] Jeon Yu Jin(전유진) _ If Only In My Dreams(하루만 나의 꿈속에 다녀가세요)','1theK (원더케이)','https://i.ytimg.com/vi/gjKuVrD1hXM/hqdefault.jpg','gjKuVrD1hXM','2026-01-08 15:20:57','2026-01-13 13:41:52'),(40,'youtube','kr_trend',10,'11녹서스 당하기;;','잡상싱','https://i.ytimg.com/vi/QSPJqvlbAUs/hqdefault.jpg','QSPJqvlbAUs','2026-01-08 15:20:57','2026-01-13 13:41:52'),(41,'youtube','us_songs',1,'Bruno Mars - I Just Might [Official Music Video]','Bruno Mars','https://i.ytimg.com/vi/mrV8kK5t0V8/hqdefault.jpg','mrV8kK5t0V8','2026-01-08 15:20:57','2026-01-13 13:41:52'),(42,'youtube','us_songs',2,'Fuerza Regida - Marlboro Rojo (Letra)','RIXELUS','https://i.ytimg.com/vi/19o3R_AVats/hqdefault.jpg','19o3R_AVats','2026-01-08 15:20:57','2026-01-13 13:41:52'),(43,'youtube','us_songs',3,'A$AP Rocky - Punk Rocky (Official Video)','ASAPROCKYUPTOWN','https://i.ytimg.com/vi/lCp0BmcFPQ8/hqdefault.jpg','lCp0BmcFPQ8','2026-01-08 15:20:57','2026-01-13 13:41:52'),(44,'youtube','us_songs',4,'A$AP ROCKY - HELICOPTER (Official Video)','ASAPROCKYUPTOWN','https://i.ytimg.com/vi/g1-46Nu3HxQ/hqdefault.jpg','g1-46Nu3HxQ','2026-01-08 15:20:57','2026-01-13 13:41:52'),(45,'youtube','us_songs',5,'Sleepless in a Hotel Room','Luke Combs - Topic','https://i.ytimg.com/vi/B9J1cAdONLU/hqdefault.jpg','B9J1cAdONLU','2026-01-08 15:20:57','2026-01-13 13:41:52'),(46,'youtube','us_songs',6,'Finesse2Tymes - Creepin [Official Music Video]','Finesse2tymes','https://i.ytimg.com/vi/WPuP-qkhkuI/hqdefault.jpg','WPuP-qkhkuI','2026-01-08 15:20:57','2026-01-13 13:41:52'),(47,'youtube','us_songs',7,'French Montana x Max B - Ever Since U Left Me (Official Video)','French Montana','https://i.ytimg.com/vi/u9rdzKwhxhI/hqdefault.jpg','u9rdzKwhxhI','2026-01-08 15:20:57','2026-01-13 13:41:52'),(48,'youtube','us_songs',8,'Polo G - 95 Bulls (feat. King Von) (Official Video)','Polo G','https://i.ytimg.com/vi/HuAfl76f7y4/hqdefault.jpg','HuAfl76f7y4','2026-01-08 15:20:57','2026-01-13 13:41:52'),(49,'youtube','us_songs',9,'MI GATA','Junior H - Topic','https://i.ytimg.com/vi/sJ7T-h6A_kg/hqdefault.jpg','sJ7T-h6A_kg','2026-01-08 15:20:57','2026-01-13 13:41:52'),(50,'youtube','us_songs',10,'6IX9INE- BACON FT. ADIN ROSS & CUFFEM (OFFICAL MUSIC VIDEO)','Tekashi 6ix9ine','https://i.ytimg.com/vi/s7l7ech1ArQ/hqdefault.jpg','s7l7ech1ArQ','2026-01-08 15:20:57','2026-01-13 13:41:52'),(51,'youtube','us_trend',1,'A$AP ROCKY - HELICOPTER (Official Video)','ASAPROCKYUPTOWN','https://i.ytimg.com/vi/g1-46Nu3HxQ/hqdefault.jpg','g1-46Nu3HxQ','2026-01-08 15:20:58','2026-01-13 13:41:52'),(52,'youtube','us_trend',2,'ONE PIECE: Season 2 | Official Teaser | Netflix','Netflix','https://i.ytimg.com/vi/OBDJgW-TJKc/hqdefault.jpg','OBDJgW-TJKc','2026-01-08 15:20:58','2026-01-13 13:41:52'),(53,'youtube','us_trend',3,'🔴LIVE | ARC RAIDERS wl Gingy & Jamarr Chase | THE TEAM LEADER CHRONICLES | #BUNGULATE','TheBurntPeanut','https://i.ytimg.com/vi/KY8q8Ne_Hpc/hqdefault.jpg','KY8q8Ne_Hpc','2026-01-08 15:20:58','2026-01-13 13:41:52'),(54,'youtube','us_trend',4,'Finesse2Tymes - Check In With Who [Official Music Video]','Finesse2tymes','https://i.ytimg.com/vi/6uhTpPZ0kZo/hqdefault.jpg','6uhTpPZ0kZo','2026-01-08 15:20:58','2026-01-13 13:41:52'),(55,'youtube','us_trend',5,'Lee Cronin’s The Mummy | Official Teaser','Warner Bros.','https://i.ytimg.com/vi/Pbn1yz2p0CU/hqdefault.jpg','Pbn1yz2p0CU','2026-01-08 15:20:58','2026-01-13 13:41:52'),(56,'youtube','us_trend',6,'This Job Ain’t Easy… (Quarantine Zone Part 2)','CaseOh','https://i.ytimg.com/vi/5LGkxW3MERg/hqdefault.jpg','5LGkxW3MERg','2026-01-08 15:20:58','2026-01-13 13:41:52'),(57,'youtube','us_trend',7,'HoneyKomb Brazy - I Remember (Official Music Video) Shot By The Director Frazier','Honeykomb Brazy','https://i.ytimg.com/vi/9HfgHB243gA/hqdefault.jpg','9HfgHB243gA','2026-01-08 15:20:58','2026-01-13 13:41:52'),(58,'youtube','us_trend',8,'Character Trailer - \"Columbina: To Where She Flies\" | Genshin Impact #GenshinImpact #Columbina','Genshin Impact','https://i.ytimg.com/vi/WsYsNoNjbaw/hqdefault.jpg','WsYsNoNjbaw','2026-01-08 15:20:58','2026-01-13 13:41:52'),(59,'youtube','us_trend',9,'Working the night shift alone...','jacksepticeye','https://i.ytimg.com/vi/06P19HnIJjs/hqdefault.jpg','06P19HnIJjs','2026-01-08 15:20:58','2026-01-13 13:41:52'),(60,'youtube','us_trend',10,'EN LA PEDA','Juniorhh - Topic','https://i.ytimg.com/vi/5kr4Ly65K8U/hqdefault.jpg','5kr4Ly65K8U','2026-01-08 15:20:58','2026-01-13 13:41:52');
/*!40000 ALTER TABLE `trends` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `google_id` varchar(255) DEFAULT NULL,
  `kakao_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `is_admin` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `profile_photo_path` varchar(2048) DEFAULT NULL,
  `public_email` varchar(255) DEFAULT NULL,
  `points` int(11) NOT NULL DEFAULT 0,
  `soundcloud_url` varchar(255) DEFAULT NULL,
  `youtube_url` varchar(255) DEFAULT NULL,
  `donation_info` text DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `daw_info` varchar(255) DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,NULL,NULL,'Lee','lee@gmail.com',0,1,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$12$4yWQoLSIORBQu/4NOxZpGuUuOOwbsogLpMPELGsWN0l92d9mgMNtu',NULL,'2026-01-01 04:57:19','2026-01-01 04:57:19'),(2,NULL,NULL,'이영','lyh@naver.com',0,1,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$12$tp9IoLNCY5NoYPqiR7iOiuS8EnziYEWKXLtH0NY3/shw9eXziGsBW',NULL,'2026-01-01 23:52:16','2026-01-05 02:17:41'),(3,NULL,NULL,'dldydhyun','dldydhyun@naver.com',0,1,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$12$x12EYDrRthVVww2yonAJo.VyL9MYeeqqUl.vcGTdHUZ2bDooChcnG',NULL,'2026-01-03 14:34:51','2026-01-03 14:34:51'),(4,NULL,NULL,'평창동사는이모씨','plpl@gmail.com',0,1,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$12$3OgIGSybBoSJ7QcZ6zqiveaBVUycYnJu6M/zkDeooipBYir4y3FXK',NULL,'2026-01-07 02:41:33','2026-01-07 02:41:33'),(5,NULL,NULL,'foreverYoung','foreveryoung@gmail.com',0,1,'profile-photos/CuWm9ws8tSyuEiLccR0YLmSMqAUZ8v3Y49tBnaCo.jpg',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$12$QB7uVtjop5rbgUjRjcroEeH8Eyvqz1t7DqY4Ijc12jKfqS6wsujOG',NULL,'2026-01-07 02:45:11','2026-01-07 02:45:11'),(6,NULL,NULL,'짱이','jjna9yi@gmail.com',0,1,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$12$QB7uVtjop5rbgUjRjcroEeH8Eyvqz1t7DqY4Ijc12jKfqS6wsujOG',NULL,'2026-01-07 02:45:38','2026-01-07 02:45:38'),(7,NULL,NULL,'Diplo_Chan','chan@gmail.com',0,1,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$12$kM8zW.vBAkoIFzG1O0B33.vrWHcjWNnlTgwuLmlPlQ.E73PYFXdwu',NULL,'2026-01-07 02:46:35','2026-01-07 02:46:35'),(8,NULL,NULL,'팜하니','newnew@gmail.com',0,1,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$12$0ko2QJ401gqdCks9PGtj3uYvnAQBw4GjIQmcDqNqtgO6UwOkegA9G',NULL,'2026-01-07 02:47:13','2026-01-07 02:47:13'),(9,'105392004737332260017',NULL,'YH LEE','lyh071111@gmail.com',1,1,'profile-photos/CuWm9ws8tSyuEiLccR0YLmSMqAUZ8v3Y49tBnaCo.jpg','dada@daum.net',0,'https://soundcloud.com/diplo','https://www.youtube.com/@Swiiim708','카카오페이\n123-123123123123','한쿡사람입니다.','Ableton Live',NULL,NULL,NULL,'2026-01-13 15:38:19','2026-01-20 04:02:09'),(10,NULL,'4697140772','Lee','lyh071111@daum.net',0,1,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-14 14:37:22','2026-01-14 14:37:22'),(11,NULL,NULL,'admin','lyh071111@naver.com',0,1,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$12$Ah/w/OguvNn4OSboxmFGEOAzWZL3ejQeUDAUqAudPMY.fxVkd80jq',NULL,'2026-01-20 03:31:04','2026-01-20 03:31:04');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `votes`
--

DROP TABLE IF EXISTS `votes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `votes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `remix_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `votes_user_id_remix_id_unique` (`user_id`,`remix_id`),
  KEY `votes_remix_id_foreign` (`remix_id`),
  CONSTRAINT `votes_remix_id_foreign` FOREIGN KEY (`remix_id`) REFERENCES `remixes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `votes_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `votes`
--

LOCK TABLES `votes` WRITE;
/*!40000 ALTER TABLE `votes` DISABLE KEYS */;
INSERT INTO `votes` VALUES (1,1,1,'2026-01-01 05:03:41','2026-01-01 05:03:41'),(2,2,1,'2026-01-04 12:43:04','2026-01-04 12:43:04');
/*!40000 ALTER TABLE `votes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `worldcup_items`
--

DROP TABLE IF EXISTS `worldcup_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `worldcup_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `worldcup_id` bigint(20) unsigned NOT NULL,
  `remix_id` bigint(20) unsigned NOT NULL,
  `win_count` int(10) unsigned NOT NULL DEFAULT 0,
  `match_count` int(10) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `worldcup_items_worldcup_id_foreign` (`worldcup_id`),
  KEY `worldcup_items_remix_id_foreign` (`remix_id`),
  CONSTRAINT `worldcup_items_remix_id_foreign` FOREIGN KEY (`remix_id`) REFERENCES `remixes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `worldcup_items_worldcup_id_foreign` FOREIGN KEY (`worldcup_id`) REFERENCES `worldcups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `worldcup_items`
--

LOCK TABLES `worldcup_items` WRITE;
/*!40000 ALTER TABLE `worldcup_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `worldcup_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `worldcups`
--

DROP TABLE IF EXISTS `worldcups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `worldcups` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `status` enum('active','finished') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `worldcups`
--

LOCK TABLES `worldcups` WRITE;
/*!40000 ALTER TABLE `worldcups` DISABLE KEYS */;
/*!40000 ALTER TABLE `worldcups` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-23 17:54:57
