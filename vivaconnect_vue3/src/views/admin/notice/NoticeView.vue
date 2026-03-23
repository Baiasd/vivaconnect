<script lang="ts" setup>
import axios from "@/utils/axios.js";
import {onMounted, ref} from 'vue'
import {dayjs, ElMessage, ElMessageBox, TableInstance} from 'element-plus'
import router from "@/router/router";
import {Plus} from "@element-plus/icons-vue";


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

// 新增通知
const onAdd = () => {
  router.push({path: '/user/notice/add'})
}

// 查看详情
const onDetail = (row: Notice) => {
  router.push({
    name: 'NoticeDetail',
    params: {nid: row.nid},
  })
}

const onEdit = (row: Notice) => {
  router.push({
    name: 'EditNotice',
    params: {nid: row.nid},
  })
}

const onDelete = (row: Notice) => {
  // 1. 添加确认弹窗（网页2、4）
  ElMessageBox.confirm(
      '此操作将永久删除该管理员，是否继续？',
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
  ).then(async () => {
    try {
      // 2. 发送删除请求（需要传递ID参数）
      await axios.delete(`/api/notice/deleteNotice?nid=${row.nid}`)

      // 3. 删除成功提示（网页6）
      ElMessage.success('删除成功')

      // 4. 刷新数据列表（网页4）
      const res = await axios.get('/api/notice/findNoticePage')
      noticePage.value = res.data.records
    } catch (error) {
      // 5. 错误处理（网页6）
      ElMessage.error('删除失败：' + error.message)
    }
  }).catch(() => {
    // 用户点击取消时的提示（网页4）
    ElMessage.info('已取消删除')
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

</script>

<template>
  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是公告管理页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled type="info">通知管理></el-link>
        <el-link disabled type="info">公告管理</el-link>
      </div>
    </el-col>
  </el-row>

  <el-card>
    <el-button :icon="Plus" type="primary" @click="onAdd" v-permission="'/notice/save'">
      新增
    </el-button>
    <el-table
        ref="multipleTableRef"
        :data="noticePage?.records"
        row-key="nid"
        style="width: 100%"
        @selection-change="handleSelectionChange"
    >
      <el-table-column type="selection" width="55"/>
      <el-table-column align="center" property="title" label="标题" width="120"/>
      <el-table-column align="center" property="createTime" label="创建时间" width="120">
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
      <el-table-column align="center" property="expireTime" label="过期时间">
        <template #default="scope">
          <span v-if="scope.row.expireTime != null">
            {{ dayjs(scope.row.expireTime).format('YYYY-MM-DD') }}
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
          <el-button link @click="onEdit(scope.row)" v-permission="'/notice/updateById'">修改</el-button>
          <el-button link @click="onDelete(scope.row)" v-permission="'/notice/deleteNotice'">删除</el-button>
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
.example-pagination-block + .example-pagination-block {
  margin-top: 10px;
}

.example-pagination-block .example-demonstration {
  margin-bottom: 16px;
}
</style>
