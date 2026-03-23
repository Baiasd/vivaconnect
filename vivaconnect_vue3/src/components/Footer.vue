<template>
  <div class="footer-content">
    <el-row :gutter="20">
      <el-col :md="8" :sm="24">
        <div class="footer-section">
          <h3>联系我们</h3>
          <p>地址：辽宁省大连市沙河口区黄河路794号</p>
          <p>邮编：116028</p>
          <p>电话：(0411)84106239</p>
          <p>邮箱：zsb@djtu.edu.cn</p>
        </div>
      </el-col>

      <el-col :md="8" :sm="24">
        <div class="footer-section">
          <h3>相关链接</h3>
          <el-link type="info" href="http://www.djtu.edu.cn/">学校官网</el-link>
          <el-link type="info" href="http://jw.djtu.edu.cn/">教务系统</el-link>
          <el-link type="info" href="http://lib.djtu.edu.cn/">图书馆</el-link>
        </div>
      </el-col>
    </el-row>

    <div class="copyright">
      <p>© 2025 大连交通大学 版权所有 辽ICP备12345678号</p>
      <p>技术支持：大连交通大学信息化中心</p>
    </div>
  </div>
</template>

<style scoped>
.main-footer {
  background: #2c3e50;
  color: #ecf0f1;
  padding: 40px 0;
}

.footer-content {
  max-width: 1200px;
  margin: 0 auto;
}

.footer-section {
  margin-bottom: 30px;
}

.footer-section h3 {
  color: #3498db;
  margin-bottom: 15px;
}

.copyright {
  text-align: center;
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid #34495e;
}

.el-link {
  display: block;
  margin: 8px 0;
}
</style>