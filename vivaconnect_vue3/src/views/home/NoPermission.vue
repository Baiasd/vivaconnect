<script setup lang="ts">
import {ArrowLeft, Warning} from "@element-plus/icons-vue";
import router from "@/router/router.js";

// 返回上一页（根据您的原始代码返回2层）
const goBack = () => {
  router.go(-2);
};

// 返回首页
const goHome = () => {
  router.push({path: '/'});
}
</script>

<template>
  <div class="permission-container">
    <div class="error-content">
      <div class="icon-wrapper">
        <el-icon class="error-icon">
          <Warning/>
        </el-icon>
      </div>

      <h1 class="error-title">403 禁止访问</h1>
      <p class="error-description">抱歉，您没有权限访问此页面</p>

      <div class="action-buttons">
        <el-button
            type="primary"
            :icon="ArrowLeft"
            @click="goBack"
            size="large"
        >
          返回上一页
        </el-button>
        <el-button
            type="info"
            @click="goHome"
            size="large"
        >
          返回首页
        </el-button>
      </div>

      <div class="contact-info">
        <p>如果您认为这是一个错误或需要帮助，请联系管理员</p>
        <el-button type="text">admin@example.com</el-button>
      </div>
    </div>

    <div class="decoration-side">
      <div class="decoration-box">
        <div class="gradient-box-1"></div>
        <div class="gradient-box-2"></div>
        <div class="gradient-box-3"></div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.permission-container {
  display: flex;
  min-height: calc(100vh - 160px);
  align-items: center;
  justify-content: space-between;
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
  gap: 3rem;
}

.error-content {
  flex: 1;
  max-width: 600px;
}

.decoration-side {
  flex: 1;
  max-width: 400px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.icon-wrapper {
  display: flex;
  justify-content: center;
  margin-bottom: 2rem;
}

.error-icon {
  font-size: 6rem;
  color: #ff7f7f;
}

.error-title {
  font-size: 2.5rem;
  font-weight: bold;
  color: #333;
  margin-bottom: 1rem;
  text-align: center;
}

.error-description {
  font-size: 1.2rem;
  color: #666;
  text-align: center;
  margin-bottom: 2.5rem;
  line-height: 1.6;
}

.action-buttons {
  display: flex;
  justify-content: center;
  gap: 1.5rem;
  margin-bottom: 2.5rem;
}

.contact-info {
  text-align: center;
  font-size: 0.95rem;
  color: #777;
  border-top: 1px solid #eee;
  padding-top: 1.5rem;
}

.contact-info p {
  margin-bottom: 0.8rem;
}

.decoration-box {
  position: relative;
  width: 320px;
  height: 320px;
}

.gradient-box-1 {
  position: absolute;
  width: 280px;
  height: 280px;
  border-radius: 35px;
  background: linear-gradient(145deg, #f0f5ff, #e0e9ff);
  top: 20px;
  left: 20px;
  transform: rotate(15deg);
  z-index: 1;
}

.gradient-box-2 {
  position: absolute;
  width: 250px;
  height: 250px;
  border-radius: 25px;
  background: linear-gradient(145deg, #fff1f1, #ffecec);
  top: 10px;
  left: 35px;
  transform: rotate(-5deg);
  z-index: 2;
}

.gradient-box-3 {
  position: absolute;
  width: 220px;
  height: 220px;
  border-radius: 20px;
  background: linear-gradient(145deg, #f8fbfe, #eef5ff);
  top: 25px;
  left: 50px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
  z-index: 3;
}

@media (max-width: 900px) {
  .permission-container {
    flex-direction: column;
    align-items: center;
    gap: 2rem;
    padding: 2rem 1rem;
  }

  .decoration-side {
    margin-top: 2rem;
  }

  .decoration-box {
    width: 260px;
    height: 260px;
  }

  .gradient-box-1 {
    width: 200px;
    height: 200px;
  }

  .gradient-box-2 {
    width: 180px;
    height: 180px;
  }

  .gradient-box-3 {
    width: 160px;
    height: 160px;
  }
}
</style>