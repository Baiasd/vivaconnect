<script lang="ts" setup>
import {useRoute, useRouter} from 'vue-router'
import {onMounted, ref} from 'vue'
import axios from "@/utils/axios";
import {ArrowLeft} from "@element-plus/icons-vue";
import {dayjs} from "element-plus";

const route = useRoute()
const router = useRouter()

interface Notice {
  nid: number
  adminId: number
  title: string
  content: string
  createTime: Date | string
  publishTime: Date | string
  expireTime: Date | string
  isTop: boolean
  viewCount: number
}

const nid = route.params.nid
const notice = ref<Notice | null>(null)

const loadNotice = async () => {
  notice.value = (await axios.get('/api/notice/findById', {
    params: {nid: nid}
  })).data
  console.log(notice.value)
}

onMounted(async () => {
  await loadNotice()
})


const goBack = () => {
  router.back();
}



</script>

<template>

  <el-button :icon="ArrowLeft" @click="goBack">返回</el-button>

  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是通知详情页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled>通知管理></el-link>
        <el-link href="/#/user/notice" type="info">通知管理></el-link>
        <el-link disabled>通知详情</el-link>
      </div>
    </el-col>
  </el-row>


  <el-descriptions title="通知详情" :column="4" border>
    <el-descriptions-item align="center" label="管理员id">{{ notice?.adminId }}</el-descriptions-item>
    <el-descriptions-item align="center" label="标题">{{ notice?.title }}</el-descriptions-item>
    <el-descriptions-item align="center" label="创建时间">{{
        dayjs(notice?.createTime).format('YYYY-MM-DD HH:mm:ss')
      }}
    </el-descriptions-item>
    <el-descriptions-item align="center" label="发布时间">{{
        dayjs(notice?.publishTime).format('YYYY-MM-DD HH:mm:ss')
      }}
    </el-descriptions-item>
    <el-descriptions-item align="center" label="详情">
      <div v-html="notice?.content"/>
    </el-descriptions-item>
  </el-descriptions>

</template>

<style scoped>
</style>