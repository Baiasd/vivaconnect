# 吉祥社区报修管理系统
基于 Spring Cloud Alibaba + Vue3 开发的智慧社区报修管理平台，支持业主报修、维修工接单、管理员派单、数据可视化统计。

## 技术栈
### 后端
- Spring Boot 3.x + Spring Cloud Alibaba
- Nacos：服务注册/配置中心
- RocketMQ：异步消息、解耦通知
- MySQL 8.0 + MyBatis-Plus
- Redis：缓存、高频数据加速
- Spring Security + 动态 RBAC 权限

### 前端
- Vue3 + Vite
- Element Plus
- Pinia
- Axios
- ECharts 数据可视化

## 核心功能
- 用户管理：业主/维修工/管理员三角色，权限隔离
- 报修工单：图文报修、状态实时追踪、评价反馈
- 工单分配：维修工自主抢单 + 管理员精准派单
- 消息通知：邮件推送工单状态、公告发布
- 数据统计：工单时效、故障分布、维修工绩效看板

## 运行环境
- JDK 17+
- MySQL 8.0
- Redis 7.x
- Nacos 2.x
- RocketMQ 5.x
- Node.js 16+

## 快速启动
### 1. 启动中间件
```
启动 Nacos、RocketMQ、MySQL、Redis
```

### 2. 后端微服务启动顺序
1. gateway（网关）
2. user-service（用户服务）
3. repair-service（报修服务）
4. notice-service（通知服务）
5. statistics-service（数据统计服务）

### 3. 前端启动
```
npm install
npm run dev
```

## 项目结构
```
vivaconnect/
├── README.md
├── vivaconnect/
│   ├── pom.xml
│   ├── vivaconnect_api/
│   │   ├── pom.xml
│   │   ├── vivaconnect_api_admin/
│   │   │   ├── pom.xml
│   │   │   └── src/
│   │   │       ├── main/
│   │   │       └── test/
│   │   ├── vivaconnect_api_mail/
│   │   │   ├── pom.xml
│   │   │   └── src/
│   │   │       ├── main/
│   │   │       └── test/
│   │   └── vivaconnect_api_message/
│   │       ├── pom.xml
│   │       └── src/
│   │           ├── main/
│   │           └── test/
│   ├── vivaconnect_commons/
│   │   ├── pom.xml
│   │   ├── vivaconnect_commons_redis/
│   │   │   ├── pom.xml
│   │   │   └── src/
│   │   │       ├── main/
│   │   │       └── test/
│   │   ├── vivaconnect_commons_utils/
│   │   │   ├── pom.xml
│   │   │   └── src/
│   │   │       ├── main/
│   │   │       └── test/
│   │   └── vivaconnect_commons_vo/
│   │       ├── pom.xml
│   │       └── src/
│   │           ├── main/
│   │           └── test/
│   ├── vivaconnect_pojo/
│   │   ├── pom.xml
│   │   ├── vivaconnect_pojo_address/
│   │   │   ├── pom.xml
│   │   │   └── src/
│   │   │       ├── main/
│   │   │       └── test/
│   │   ├── vivaconnect_pojo_notice/
│   │   │   ├── pom.xml
│   │   │   └── src/
│   │   │       ├── main/
│   │   │       └── test/
│   │   ├── vivaconnect_pojo_repair/
│   │   │   ├── pom.xml
│   │   │   └── src/
│   │   │       └── ...
│   │   └── vivaconnect_pojo_user/
│   │       ├── pom.xml
│   │       └── src/
│   ├── vivaconnect_service/
│   │   ├── pom.xml
│   │   ├── vivaconnect_service_admin/
│   │   │   ├── pom.xml
│   │   │   └── src/
│   │   ├── vivaconnect_service_mail/
│   │   │   ├── pom.xml
│   │   │   └── src/
│   │   └── vivaconnect_service_message/
│   │       ├── HELP.md
│   │       ├── mvnw
│   │       ├── mvnw.cmd
│   │       ├── pom.xml
│   │       └── src/
│   └── vivaconnect_web/
│       ├── pom.xml
│       ├── vivaconnect_web_admin/
│       │   ├── pom.xml
│       │   └── src/
│       └── vivaconnect_web_user/
│           ├── pom.xml
│           └── src/
├── vivaconnect-vue3/
│   ├── index.html
│   ├── jsconfig.json
│   ├── package.json
│   ├── README.md
│   ├── vite.config.js
│   ├── public/
│   │   └── favicon.ico
│   └── src/
│       ├── admin_config.js
│       ├── App.vue
│       ├── main.js
│       ├── assets/
│       │   └── logo.svg
│       ├── components/
│       │   ├── Aside.vue
│       │   ├── DeleteBtn.vue
│       │   ├── Footer.vue
│       │   └── Header.vue
│       ├── layout/
│       │   └── AdminLayout.vue
│       ├── router/
│       │   └── router.js
│       ├── store/
│       │   └── store.js
│       ├── utils/
│       │   └── axios.js
│       └── views/
│           ├── backstage/
│           ├── home/
│           ├── repair/
│           └── user/
└── 文档/
    ├── 接口文档.md
    ├── 吉祥社区报修管理系统软件使用说明书.pdf
    └── 吉祥社区报修管理系统软件安装说明书.pdf
```

## 配套文档
- 接口文档
- 软件安装说明书
- 软件使用说明书

## 说明
本科毕业设计项目，仅供学习交流使用。
