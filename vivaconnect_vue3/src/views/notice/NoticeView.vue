<script lang="ts" setup>
import axios from "@/utils/axios.js";
import {onMounted, ref} from 'vue'
import {dayjs, ElMessage, ElMessageBox, TableInstance} from 'element-plus'
import router from "@/router/router";
import {ArrowLeft, Plus} from "@element-plus/icons-vue";


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

interface NoticePage {
  records: Notice[]
  total: number
  size: number
  current: number
  pages: number
}

const multipleTableRef = ref<TableInstance>()
const multipleSelection = ref<Notice[]>([])
const noticePage = ref<NoticePage>() // 存储从API获取的数据

const toggleSelection = (rows?: Notice[], ignoreSelectable?: boolean) => {
  if (rows) {
    rows.forEach((row) => {
      multipleTableRef.value!.toggleRowSelection(
          row,
          undefined,
          ignoreSelectable
      )
    })
  } else {
    multipleTableRef.value!.clearSelection()
  }
}
const handleSelectionChange = (val: Notice[]) => {
  multipleSelection.value = val
}


const loadNoticePage = async () => {
  noticePage.value = (await axios.get('/api/notice/findNoticePage')).data
}

onMounted(async () => {
  await loadNoticePage()
})

// 查看详情
const onDetail = (row: Notice) => {
  router.push({
    name: 'NoticeDetail',
    params: {nid: row.nid},
  })
}


const handleSizeChange = (val: number) => {
  console.log(`${val} items per page`)
}
const handleCurrentChange = (val: number) => {
  console.log(`current page: ${val}`)
  axios.get('/api/notice/findNoticePage', {
    params: {page: val}
  }).then(data => {
    noticePage.value = data.data;
    console.log(noticePage.value)
    console.log(data.data)
  })
}

const goBack = () => {
  router.back();
}
</script>

<template>

  <el-button :icon="ArrowLeft" @click="goBack">返回</el-button>

  <el-card style="margin: 20px">
    <el-table
        ref="multipleTableRef"
        :data="noticePage?.records"
        row-key="nid"
        style="width: 100%"
        @selection-change="handleSelectionChange"
    >
      <el-table-column align="center" property="title" label="标题"/>
      <el-table-column align="center" property="createTime" label="创建时间">
        <template #default="scope">
          <span v-if="scope.row.createTime != null">
            {{ dayjs(scope.row.createTime).format('YYYY-MM-DD') }}
          </span>
          <span v-else>永久</span>
        </template>
      </el-table-column>
      <el-table-column align="center" property="publishTime" label="发布时间">
        <template #default="scope">
          <span v-if="scope.row.publishTime != null">
            {{ dayjs(scope.row.publishTime).format('YYYY-MM-DD') }}
          </span>
          <span v-else>永久</span>
        </template>
      </el-table-column>

      <el-table-column align="center" property="viewCount" label="浏览量">
        <template #default="scope">
          <span v-if="scope.row.viewCount == null">0</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="操作">
        <template #default="scope">
          <el-button link @click="onDetail(scope.row)">查看详情</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div style="margin-top: 20px">
      <el-button @click="toggleSelection()">清空选择</el-button>
      <div class="example-pagination-block">
        <el-pagination layout="prev, pager, next" :total="noticePage?.total" @size-change="handleSizeChange"
                       @current-change="handleCurrentChange"/>
      </div>
    </div>
  </el-card>

</template>


<style scoped>

</style>
