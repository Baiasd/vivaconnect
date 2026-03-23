<template>
  <el-container>
    <el-header style="line-height: 60px">
      <Header/>
    </el-header>
    <el-container>
      <el-aside>
        <Aside/>
      </el-aside>
      <el-container>
        <el-main>
          <router-view :key="$route.fullPath"/>
        </el-main>
        <el-footer>
          <Footer/>
        </el-footer>
      </el-container>
    </el-container>
  </el-container>
</template>
<script setup lang="ts">
import Footer from "@/components/Footer.vue";
import Header from "@/components/Header.vue";
import Aside from "@/components/Aside.vue";

import {useRoute} from "vue-router";

const route = useRoute()

console.log(route.fullPath)
</script>