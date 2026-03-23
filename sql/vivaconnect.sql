/*
 Navicat Premium Dump SQL

 Source Server         : 社区报修管理系统
 Source Server Type    : MySQL
 Source Server Version : 80031 (8.0.31)
 Source Host           : 192.168.72.128:3306
 Source Schema         : vivaconnect

 Target Server Type    : MySQL
 Target Server Version : 80031 (8.0.31)
 File Encoding         : 65001

 Date: 06/06/2025 14:24:36
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for area
-- ----------------------------
DROP TABLE IF EXISTS `area`;
CREATE TABLE `area`  (
  `aid` int NOT NULL AUTO_INCREMENT COMMENT '区域ID',
  `area_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '区域名称',
  `create_time` datetime NULL DEFAULT NULL COMMENT '建立时间',
  `status` enum('启用','停用','在建') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态',
  `area` decimal(10, 2) NULL DEFAULT NULL COMMENT '面积',
  PRIMARY KEY (`aid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '区域表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of area
-- ----------------------------
INSERT INTO `area` VALUES (1, '东区', '2025-05-21 16:00:00', '启用', 10000.00);
INSERT INTO `area` VALUES (2, '西区', '2025-05-14 14:54:14', '停用', 10000.00);
INSERT INTO `area` VALUES (3, '南区', '2025-05-14 14:54:14', '启用', 10000.00);
INSERT INTO `area` VALUES (4, '北区', '2025-06-04 16:00:00', '启用', 20000.00);

-- ----------------------------
-- Table structure for building
-- ----------------------------
DROP TABLE IF EXISTS `building`;
CREATE TABLE `building`  (
  `bid` int NOT NULL AUTO_INCREMENT COMMENT '楼宇ID',
  `aid` int NULL DEFAULT NULL COMMENT '区域ID',
  `building_name` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '楼号',
  `floor_total` tinyint NOT NULL COMMENT '总楼层数',
  `floor_ground` tinyint NOT NULL COMMENT '地上层数',
  `floor_underground` tinyint NOT NULL COMMENT '地下层数',
  `building_purpose` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用途',
  `construction_time` datetime NULL DEFAULT NULL COMMENT '建成时间',
  `total_area` decimal(10, 2) NULL DEFAULT NULL COMMENT '建筑面积',
  `is_closed` tinyint(1) NULL DEFAULT 0 COMMENT '是否封闭式管理',
  `elevator_count` tinyint NULL DEFAULT NULL COMMENT '电梯数量',
  `fire_system_status` enum('正常','异常','未知') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '未知' COMMENT '消防状态',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `status` enum('启用','停用','在建') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态',
  PRIMARY KEY (`bid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '楼宇表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of building
-- ----------------------------
INSERT INTO `building` VALUES (1, 1, '01', 20, 15, 5, '住宅', '2025-05-18 13:27:44', 10000.00, 1, 5, '正常', '2025-05-18 13:28:20', '启用');

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment`  (
  `cid` int NOT NULL AUTO_INCREMENT COMMENT '评价ID',
  `owner_id` int NULL DEFAULT NULL COMMENT '业主ID',
  `rating` double NULL DEFAULT NULL COMMENT '评分',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '评价详情',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `comment_time` datetime NULL DEFAULT NULL COMMENT '评价时间',
  `reply_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '物业回复',
  `reply_time` datetime NULL DEFAULT NULL COMMENT '回复时间',
  PRIMARY KEY (`cid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '评价表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of comment
-- ----------------------------
INSERT INTO `comment` VALUES (1, 1, 4, '<ul><li><span style=\"font-size: 32px;\"><strong>asdasdw</strong></span></li></ul><p><img src=\"http://192.168.6.128:8888/group1/M00/00/01/wKgGgGgu4OCAG4_pAAPAONxpn34135.png\" alt=\"\" data-href=\"\" style=\"width: 458.00px;height: 491.50px;\"/></p>', '2025-05-22 06:51:55', '2025-05-23 04:30:09', 'sdasdwasdw', '2025-05-23 04:30:49');
INSERT INTO `comment` VALUES (2, NULL, 4, '', '2025-05-22 06:51:55', NULL, 'asdwad', '2025-06-05 06:15:38');
INSERT INTO `comment` VALUES (3, NULL, 4.1, '', '2025-05-22 06:51:55', NULL, NULL, NULL);
INSERT INTO `comment` VALUES (4, NULL, 5, '', '2025-05-22 06:51:55', NULL, NULL, NULL);
INSERT INTO `comment` VALUES (5, NULL, 4.2, '', '2025-05-22 06:51:55', NULL, NULL, NULL);
INSERT INTO `comment` VALUES (6, NULL, 0, NULL, '2025-06-04 07:20:30', NULL, 'asdwadasd', '2025-06-05 06:19:26');
INSERT INTO `comment` VALUES (7, NULL, NULL, NULL, '2025-06-04 07:31:37', NULL, NULL, NULL);

-- ----------------------------
-- Table structure for fault_type
-- ----------------------------
DROP TABLE IF EXISTS `fault_type`;
CREATE TABLE `fault_type`  (
  `fid` int NOT NULL AUTO_INCREMENT COMMENT '故障类型ID',
  `fault_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '故障类型',
  `job_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '综合维修工',
  `urgency` int NOT NULL DEFAULT 3,
  PRIMARY KEY (`fid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '故障类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fault_type
-- ----------------------------
INSERT INTO `fault_type` VALUES (1, '水管故障', '水暖工/管道工​', 2);
INSERT INTO `fault_type` VALUES (2, '电梯故障', '综合维修工', 3);
INSERT INTO `fault_type` VALUES (3, '空调故障', '综合维修工', 3);
INSERT INTO `fault_type` VALUES (4, '未知', '综合维修工', 2);

-- ----------------------------
-- Table structure for job_type
-- ----------------------------
DROP TABLE IF EXISTS `job_type`;
CREATE TABLE `job_type`  (
  `jid` int NOT NULL AUTO_INCREMENT,
  `job_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`jid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of job_type
-- ----------------------------
INSERT INTO `job_type` VALUES (1, '综合维修工');
INSERT INTO `job_type` VALUES (2, '电工​');
INSERT INTO `job_type` VALUES (3, '水暖工/管道工​');
INSERT INTO `job_type` VALUES (4, '​​空调维修工​');
INSERT INTO `job_type` VALUES (5, '电梯维护工​');
INSERT INTO `job_type` VALUES (6, '漏水维修工​');
INSERT INTO `job_type` VALUES (7, '消防设施维护工​');
INSERT INTO `job_type` VALUES (8, '​​绿化养护工​');
INSERT INTO `job_type` VALUES (9, '清洁维护工​');
INSERT INTO `job_type` VALUES (10, '应急维修工');

-- ----------------------------
-- Table structure for maintainer_detail
-- ----------------------------
DROP TABLE IF EXISTS `maintainer_detail`;
CREATE TABLE `maintainer_detail`  (
  `mid` int NOT NULL AUTO_INCREMENT,
  `real_name` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `id_card` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `gender` enum('男','女','无') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `birthday` date NULL DEFAULT NULL,
  `age` int NULL DEFAULT NULL,
  `job_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `salary` decimal(10, 2) NOT NULL,
  `certificate_of_skill` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `last_update_time` datetime NULL DEFAULT NULL,
  `status` enum('空闲','在忙','休息') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '空闲',
  PRIMARY KEY (`mid`) USING BTREE,
  UNIQUE INDEX `id_card`(`id_card` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '维修工详情表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of maintainer_detail
-- ----------------------------
INSERT INTO `maintainer_detail` VALUES (1, '不正常', '210122000000000000', '男', '2024-04-07', 1, '水暖工/管道工​', 2000.00, 'group1/M00/00/00/wKgGgGgrEtKAPrEsAAL5uD82fdE344.png', NULL, '在忙');

-- ----------------------------
-- Table structure for notice
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice`  (
  `nid` int NOT NULL AUTO_INCREMENT COMMENT '公告id',
  `admin_id` int NULL DEFAULT NULL COMMENT '管理员id',
  `title` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告正文',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `publish_time` datetime NULL DEFAULT NULL COMMENT '发布时间',
  `view_count` int NULL DEFAULT NULL COMMENT '浏览次数',
  `status` enum('待发布','已发布') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '待发布' COMMENT '通知状态',
  PRIMARY KEY (`nid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 46 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '公告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notice
-- ----------------------------
INSERT INTO `notice` VALUES (1, 1, '111111', '<blockquote><s><u><em><strong>11啊啊2</strong></em></u></s></blockquote>', '2025-05-16 04:58:12', NULL, 12, '待发布');
INSERT INTO `notice` VALUES (24, 1, 'aaa', '<p>bbb</p>', '2025-05-25 05:57:03', '2025-05-26 00:00:00', 8, '已发布');
INSERT INTO `notice` VALUES (25, 1, 'aaa', '<p>aaa</p>', '2025-05-25 05:57:45', NULL, NULL, '已发布');
INSERT INTO `notice` VALUES (26, 1, 'aaa', '<p>aaa</p>', '2025-05-25 05:57:45', NULL, NULL, '已发布');
INSERT INTO `notice` VALUES (27, 1, 'aaa', '<p>aaa</p>', '2025-05-25 05:57:45', NULL, NULL, '已发布');
INSERT INTO `notice` VALUES (28, 1, 'aaa', '<p>aaa</p>', '2025-05-25 05:58:29', NULL, NULL, '已发布');
INSERT INTO `notice` VALUES (45, 1, 'aaaa', '<p>aaaa</p>', '2025-05-25 06:33:59', '2025-05-25 06:34:00', NULL, '已发布');

-- ----------------------------
-- Table structure for owner_detail
-- ----------------------------
DROP TABLE IF EXISTS `owner_detail`;
CREATE TABLE `owner_detail`  (
  `oid` int NOT NULL AUTO_INCREMENT,
  `real_name` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `id_card` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `gender` enum('男','女','无') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `birthday` date NULL DEFAULT NULL,
  `age` int NULL DEFAULT NULL,
  `area` int NULL DEFAULT NULL,
  `building` int NULL DEFAULT NULL,
  `room` int NULL DEFAULT NULL,
  `house_ownership_certificate` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`oid`) USING BTREE,
  UNIQUE INDEX `id_card`(`id_card` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '业主详情表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of owner_detail
-- ----------------------------
INSERT INTO `owner_detail` VALUES (1, '不支持', '210122000000000000', '男', '2023-04-04', 2, 1, 1, 1, 'group1/M00/00/00/wKhIgGhAGj-ABqv2AAPAONxpn34297.png', NULL);

-- ----------------------------
-- Table structure for permission
-- ----------------------------
DROP TABLE IF EXISTS `permission`;
CREATE TABLE `permission`  (
  `pid` int NOT NULL AUTO_INCREMENT,
  `permission_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `permission_desc` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `permission_type` enum('业主','维修工','管理员','所有角色') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`pid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of permission
-- ----------------------------
INSERT INTO `permission` VALUES (1, '添加用户', '/api/user/add', '所有角色');
INSERT INTO `permission` VALUES (12, '修改用户', '/api/user/edit', '所有角色');

-- ----------------------------
-- Table structure for repair_order
-- ----------------------------
DROP TABLE IF EXISTS `repair_order`;
CREATE TABLE `repair_order`  (
  `rid` int NOT NULL AUTO_INCREMENT COMMENT '工单ID',
  `owner_id` int NOT NULL COMMENT '业主ID',
  `maintainer_id` int NULL DEFAULT NULL COMMENT '维修工ID',
  `comment_id` int NULL DEFAULT NULL COMMENT '评价表id',
  `fault_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '故障类型',
  `job_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '所需工种',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '故障描述',
  `area_name` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '区域名称',
  `building_name` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '楼号',
  `room_number` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '房号',
  `status` enum('草稿','待分配','处理中','已完成','未完成') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '草稿' COMMENT '工单状态',
  `urgency` tinyint NOT NULL COMMENT '紧急程度(1-3)',
  `images` json NULL COMMENT '图片URL列表',
  `create_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `assigned_at` datetime NULL DEFAULT NULL COMMENT '分配时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '完成时间',
  PRIMARY KEY (`rid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of repair_order
-- ----------------------------
INSERT INTO `repair_order` VALUES (1, 1, 1, 2, '未知', NULL, NULL, '东区', '01', '10203', '已完成', 3, '[{\"url\": \"group1/M00/00/00/wKgGgGgtl56AH07iAAPAONxpn34789.png\"}]', '2025-05-21 09:06:55', NULL, '2025-05-22 06:27:19');
INSERT INTO `repair_order` VALUES (2, 1, 2, NULL, '水管故障', '水暖工/管道工​', NULL, '东区', '01', '10203', '处理中', 1, '[{\"url\": \"http://192.168.72.128:8888/group1/M00/00/00/wKgGgGgtl56AH07iAAPAONxpn34789.png\"}]', '2025-05-21 09:06:55', '2025-06-05 06:10:19', NULL);
INSERT INTO `repair_order` VALUES (3, 1, 1, 1, '电梯故障', NULL, NULL, '东区', '01', '10203', '已完成', 3, '[{\"url\": \"group1/M00/00/00/wKgGgGgtl56AH07iAAPAONxpn34789.png\"}]', '2025-05-29 09:06:55', NULL, '2025-05-22 06:29:20');
INSERT INTO `repair_order` VALUES (18, 1, 1, 7, '未知', NULL, 'dasdwa', '东区', '01', '10203', '未完成', 1, '[{\"url\": \"http://192.168.6.128:8888/group1/M00/00/01/wKgGgGguxJKANLHcAAL5uD82fdE920.png\"}]', '2025-05-22 06:30:51', '2025-05-23 06:20:13', NULL);
INSERT INTO `repair_order` VALUES (19, 1, 1, 3, '未知', '综合维修工', 'dasdwa', '东区', '01', '10203', '已完成', 1, '[{\"url\": \"group1/M00/00/01/wKgGgGguxJKANLHcAAL5uD82fdE920.png\"}]', '2025-05-22 06:31:44', '2025-06-04 07:14:38', '2025-06-04 07:20:31');
INSERT INTO `repair_order` VALUES (20, 1, 1, NULL, '未知', NULL, 'dasdwa', '东区', '01', '10203', '未完成', 3, '[{\"url\": \"group1/M00/00/01/wKgGgGguxJKANLHcAAL5uD82fdE920.png\"}]', '2025-05-29 06:32:28', NULL, '2025-05-30 14:50:00');
INSERT INTO `repair_order` VALUES (21, 1, 1, 1, '未知', NULL, 'dasdwa', '东区', '01', '10203', '已完成', 3, '[{\"url\": \"group1/M00/00/01/wKgGgGguxJKANLHcAAL5uD82fdE920.png\"}]', '2025-05-22 06:32:29', NULL, '2025-05-22 06:51:55');
INSERT INTO `repair_order` VALUES (22, 1, NULL, NULL, '未知', NULL, 'dasdwa', '东区', '01', '10203', '未完成', 3, '[{\"url\": \"group1/M00/00/01/wKgGgGguxJKANLHcAAL5uD82fdE920.png\"}]', '2025-05-29 06:32:30', NULL, NULL);
INSERT INTO `repair_order` VALUES (23, 1, NULL, NULL, '水管故障', NULL, 'dasdwadsw', '东区', '', '10203', '草稿', 2, '[{\"url\": \"group1/M00/00/00/wKhIgGhAJF-ASj6dAAL5uD82fdE848.png\"}]', '2025-06-04 10:05:46', NULL, NULL);

-- ----------------------------
-- Table structure for role
-- ----------------------------
DROP TABLE IF EXISTS `role`;
CREATE TABLE `role`  (
  `rid` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `role_desc` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `role_type` enum('业主','维修工','管理员') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`rid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of role
-- ----------------------------
INSERT INTO `role` VALUES (1, '业主', '业主', '业主');
INSERT INTO `role` VALUES (2, '维修工', '维修工', '维修工');
INSERT INTO `role` VALUES (3, '管理员', '管理员', '管理员');

-- ----------------------------
-- Table structure for role_permission
-- ----------------------------
DROP TABLE IF EXISTS `role_permission`;
CREATE TABLE `role_permission`  (
  `rid` int NOT NULL COMMENT '角色ID',
  `pid` int NOT NULL COMMENT '权限ID',
  PRIMARY KEY (`rid`, `pid`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色权限关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of role_permission
-- ----------------------------
INSERT INTO `role_permission` VALUES (1, 1);
INSERT INTO `role_permission` VALUES (1, 12);
INSERT INTO `role_permission` VALUES (2, 1);
INSERT INTO `role_permission` VALUES (3, 1);

-- ----------------------------
-- Table structure for room
-- ----------------------------
DROP TABLE IF EXISTS `room`;
CREATE TABLE `room`  (
  `rid` int NOT NULL AUTO_INCREMENT COMMENT '住房ID',
  `bid` int NULL DEFAULT NULL COMMENT '楼宇ID',
  `room_number` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '房号',
  `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否已售出',
  `sale_time` datetime NULL DEFAULT NULL COMMENT '售出时间',
  `owner_id` int NULL DEFAULT NULL COMMENT '所有者ID',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '备注信息',
  PRIMARY KEY (`rid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '住房表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of room
-- ----------------------------
INSERT INTO `room` VALUES (1, 1, '10203', 1, '2025-05-18 15:02:26', 1, '2025-05-18 15:02:36', '无');
INSERT INTO `room` VALUES (2, 1, '10204', 0, '2025-05-18 15:02:26', 1, '2025-05-18 15:02:36', '无');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `uid` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `avatar_url` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `role_type` enum('业主','维修工','管理员') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `email` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `detail` int NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`uid`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `phone`(`phone` ASC) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'bai', '$2a$10$EuWUPvAmPJvqXcFLQTe3M.2S55HgrcS/rCansv69Bi8Q3.TScyfQG', 'group1/M00/00/00/wKhIgGhAGj-ABqv2AAPAONxpn34297.png', '管理员', '18240404842', '2015761045@qq.com', 1, '2025-04-25 07:42:24');
INSERT INTO `user` VALUES (2, 'b', '$2a$10$EuWUPvAmPJvqXcFLQTe3M.2S55HgrcS/rCansv69Bi8Q3.TScyfQG', 'group1/M00/00/00/wKhIgGhAGj-ABqv2AAPAONxpn34297.png', '维修工', '18240404823', '2015761045@', 1, '2025-04-25 07:42:24');
INSERT INTO `user` VALUES (3, 'c', '$2a$10$EuWUPvAmPJvqXcFLQTe3M.2S55HgrcS/rCansv69Bi8Q3.TScyfQG', 'group1/M00/00/00/wKhIgGhAGj-ABqv2AAPAONxpn34297.png', '业主', '18240404824', '2015761045@q', 1, '2025-04-25 07:42:24');
INSERT INTO `user` VALUES (4, 'd', '$2a$10$EuWUPvAmPJvqXcFLQTe3M.2S55HgrcS/rCansv69Bi8Q3.TScyfQG', 'group1/M00/00/00/wKhIgGhAGj-ABqv2AAPAONxpn34297.png', '业主', '18240404825', '2015761045@qq', 1, '2025-04-25 07:42:24');
INSERT INTO `user` VALUES (6, 'f', '$2a$10$EuWUPvAmPJvqXcFLQTe3M.2S55HgrcS/rCansv69Bi8Q3.TScyfQG', 'group1/M00/00/00/wKhIgGhAGj-ABqv2AAPAONxpn34297.png', '业主', '18240404827', '2015761045@qq.c', 1, '2025-04-25 07:42:24');
INSERT INTO `user` VALUES (21, '201576', '$2a$10$.ZVKIjbzxebqB9wvEK3DGuRcscaoeTIOJRXBERx9ZPhVdGMUaxo2S', '', '管理员', '18240404852', '2783328669@qq.com', NULL, '2025-06-05 05:19:23');

-- ----------------------------
-- Table structure for user_role
-- ----------------------------
DROP TABLE IF EXISTS `user_role`;
CREATE TABLE `user_role`  (
  `uid` int NOT NULL COMMENT '用户ID',
  `rid` int NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`uid`, `rid`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_role
-- ----------------------------
INSERT INTO `user_role` VALUES (1, 3);
INSERT INTO `user_role` VALUES (2, 2);
INSERT INTO `user_role` VALUES (3, 2);
INSERT INTO `user_role` VALUES (4, 1);
INSERT INTO `user_role` VALUES (6, 2);

SET FOREIGN_KEY_CHECKS = 1;
