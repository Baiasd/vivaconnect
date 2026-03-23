<template>
  <el-container>
    <el-header style="line-height: 60px">
      <Header/>
    </el-header>
    <el-main>
      <router-view :key="$route.fullPath"/>
    </el-main>
    <el-footer>
      <Footer/>
    </el-footer>
  </el-container>
</template>
<script setup lang="ts">
import Footer from "@/components/Footer.vue";
import Header from "@/components/Header.vue";
</script>