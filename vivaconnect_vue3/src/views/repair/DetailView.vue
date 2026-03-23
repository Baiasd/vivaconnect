<script setup lang="ts">

import {computed, onMounted, reactive} from "vue";
import axios from "@/utils/axios";
import {dayjs} from 'element-plus'
import {useRoute} from "vue-router";
import {ArrowLeft} from "@element-plus/icons-vue";
import router from "@/router/router";


interface User {
  uid: number
  username: string
  password: string
  avatarUrl: string
  roleType: string
  phone: string
  email: string
  detail: number
  createdAt: Date | string
}

interface RepairOrder {
  rid: number
  ownerId: number
  maintainerId: number
  commentId: number
  faultType: string
  description: string
  areaName: string
  buildingName: string
  roomNumber: string
  status: string
  urgency: number
  images: { url: string }[]
  materials: []
  cost: number
  createAt: string
  assignedAt: string
  completedAt: string
}

interface Comment {
  cid: number
  ownerId: number
  rating: number
  content: string
  isAnonymous: number
  createTime: Date | string
  replyContent: string
  replyTime: Date | string
}

const route = useRoute()

const rid = Number(route.params.rid)
const repairOrder = reactive<RepairOrder>({images: [] as { url: string }[]} as RepairOrder);
const comment = reactive({} as Comment)

const user = reactive({} as User);
const loadUser = (async () => {
  const userData = (await axios.get('/api/user/getById', {
    params: {
      uid: repairOrder.maintainerId
    }
  })).data
  Object.assign(user, userData)
  console.log("用户信息：", user)
})

const loadOrder = (async (rid: number) => {
  const orderData = (await axios.get(`/api/repair/repairOrder/findById`, {
    params: {rid: rid}
  })).data
  Object.assign(repairOrder, orderData)
  console.log("订单信息：", orderData)
  console.log(repairOrder.images?.[0].url)
})

const loadComment = async () => {
  const commentData = (await axios.get('/api/repair/comment/findComment', {
    params: {cid: repairOrder.commentId}
  })).data
  Object.assign(comment, commentData)
  console.log(comment)
}

onMounted(async () => {
  await loadOrder(rid)
  if (repairOrder.commentId != null) {
    await loadComment()
  }
  if (repairOrder.maintainerId != null) {
    await loadUser()
  }
})

const imageUrlList = computed(() =>
    repairOrder.images?.map(img => img.url) || []
);


const goBack = () => {
  router.back();
}
</script>

<template>
  <el-button :icon="ArrowLeft" @click="goBack">返回</el-button>

  <el-descriptions title="工单详情" :column="5" border>
    <el-descriptions-item align="center" label="故障类型">{{ repairOrder.faultType }}</el-descriptions-item>
    <el-descriptions-item align="center" label="地址">{{
        repairOrder.areaName + repairOrder.buildingName + "栋" + repairOrder.roomNumber + "间"
      }}
    </el-descriptions-item>
    <el-descriptions-item align="center" label="紧急程度">{{ repairOrder.urgency }}</el-descriptions-item>
    <el-descriptions-item align="center" label="维修工电话" v-if="user">{{ user.phone }}</el-descriptions-item>
    <el-descriptions-item align="center" label="创建时间">{{
        dayjs(repairOrder.createAt).format('YYYY-MM-DD HH:mm:ss')
      }}
    </el-descriptions-item>
    <el-descriptions-item align="center" label="分配时间">{{
        dayjs(repairOrder.assignedAt).format('YYYY-MM-DD HH:mm:ss')
      }}
    </el-descriptions-item>
    <el-descriptions-item align="center" label="完成时间">{{
        dayjs(repairOrder.completedAt).format('YYYY-MM-DD HH:mm:ss')
      }}
    </el-descriptions-item>
    <el-descriptions-item align="center" label="问题描述">{{ repairOrder.description }}</el-descriptions-item>

    <el-descriptions-item align="center" label="故障图片">
      <label>点看查看所有图片</label>
      <el-image
          style="width: 200px; height: 200px"
          :src="repairOrder.images?.[0].url"
          :zoom-rate="1.2"
          :max-scale="7"
          :min-scale="0.2"
          :preview-src-list="imageUrlList"
          show-progress
          :initial-index="4"
          fit="cover"
          v-if="repairOrder.images?.length"
      />
    </el-descriptions-item>
  </el-descriptions>
  <el-descriptions :column="1" border v-if="comment.createTime != null">
    <el-descriptions-item align="center" label="评分" label-width="120">
      <el-rate v-model="comment.rating" disabled/>
    </el-descriptions-item>
    <el-descriptions-item align="center" label="评价内容">
      <div v-html="comment.content"/>
    </el-descriptions-item>
    <el-descriptions-item align="center" label="管理员回复">{{ comment.replyContent }}</el-descriptions-item>
    <el-descriptions-item align="center" label="回复时间">{{ comment.replyTime }}</el-descriptions-item>
  </el-descriptions>
  <div class="demo-image__preview">

  </div>
</template>

<style scoped>

</style>