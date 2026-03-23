<script lang="ts" setup>
import axios from "@/utils/axios.js";
import {onMounted, reactive, ref} from 'vue'
import {dayjs, ElMessage, ElMessageBox, TableInstance} from 'element-plus'
import router from "@/router/router";
import {Plus} from "@element-plus/icons-vue";

interface Area {
  aid: number
  areaName: string
  status: string
  createTime: Date | string
  area: number
}

interface Building {
  bid: number
  aid: number
  buildingName: string
  floorTotal: number
  floorGround: number
  floorUnderground: number
  buildingPurpose: string
  constructionTime: Date | string
  totalArea: number
  isClosed: boolean
  elevatorCount: number
  fireSystemStatus: boolean
  updateTime: Date | string
}

interface BuildingPage {
  records: Building[]
  total: number
  size: number
  current: number
  pages: number
}

const multipleTableRef = ref<TableInstance>()
const multipleSelection = ref<Building[]>([])
const buildingPage = ref<BuildingPage>() // 存储从API获取的数据
const areaList = ref<Area[]>([]) // 存储从API获取的数据
const area = reactive({aid: 1} as Area) // 存储从API获取的数据

const toggleSelection = (rows?: Building[], ignoreSelectable?: boolean) => {
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
const handleSelectionChange = (val: Building[]) => {
  multipleSelection.value = val
}

const loadAreaList = async () => {
  areaList.value = await (await axios.get('/api/address/area/findAreaList')).data
  console.log("区域列表：", areaList.value)
}


const loadBuildingPage = async () => {
  console.log(area.aid)
  buildingPage.value = (await axios.get('/api/address/building/findBuildingPageByAid', {
    params: {
      aid: area.aid,
    }
  })).data
  console.log("楼宇列表：", buildingPage.value)
}

onMounted(async () => {
  await loadAreaList()
  await loadBuildingPage()
  console.log(area)
})


// 新增管理用户
const onAdd = () => {
  router.push({path: '/user/address/building/add'})
}

const onEdit = (row: Building) => {
  console.log(row.bid)
  router.push({
    name: 'EditBuilding',
    params: {
      bid: row.bid,
    }
  })
}

const onDelete = (row: Building) => {
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
      await axios.delete(`/api/address/building/removeById`, {
        params: {
          bid: row.bid
        }
      })

      // 3. 删除成功提示（网页6）
      ElMessage.success('删除成功')

      // 4. 刷新数据列表（网页4）
      if (area == null) {
        await loadBuildingPage()
      } else {
        await loadBuildingPage()
      }

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

  axios.get('/api/address/building/findBuildingPageByAid', {
    params: {
      page: val,
      aid: area.aid
    }
  }).then(data => {
    buildingPage.value = data.data;
    console.log(buildingPage.value)
  })
}

</script>

<template>
  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是楼宇管理页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled type="info">地址管理></el-link>
        <el-link disabled type="info">楼宇管理</el-link>
      </div>
    </el-col>
  </el-row>

  <el-card>
    <el-row class="row-bg" justify="space-between">
      <el-col :span="4">
        <el-button :icon="Plus" type="primary" @click="onAdd">
          新增
        </el-button>
      </el-col>
      <el-col :span="4">
        <el-select
            v-model="area.aid"
            placeholder="Select"
            size="large"
            style="width: 100%"
            @change="loadBuildingPage"
        >
          <el-option
              v-for="item in areaList"
              :key="item.aid"
              :label="item.areaName"
              :value="item.aid"
          />
        </el-select>
      </el-col>
    </el-row>

    <el-table
        ref="multipleTableRef"
        :data="buildingPage?.records"
        row-key="bid"
        style="width: 100%"
        empty-text="暂无数据"
        @selection-change="handleSelectionChange"
    >
      <el-table-column align="center" property="buildingName" label="楼号"/>
      <el-table-column align="center" property="floorTotal" label="总楼层数"/>
      <el-table-column align="center" property="floorGround" label="地上层数"/>
      <el-table-column align="center" property="floorUnderground" label="地下层数"/>
      <el-table-column align="center" property="elevatorCount" label="电梯数量"/>
      <el-table-column align="center" property="buildingPurpose" label="用途"/>
      <el-table-column align="center" property="isClosed" label="封闭式管理">
        <template #default="scope">
          <span v-if="scope.row.isClosed == 1">是</span>
          <span v-if="scope.row.isClosed == 0">否</span>
        </template>
      </el-table-column>
      <el-table-column align="center" property="fireSystemStatus" label="消防状态"/>
      <el-table-column align="center" property="totalArea" label="建筑面积"/>
      <el-table-column align="center" property="constructionTime" label="建成时间">
        <template #default="scope">
          {{ dayjs(scope.row.constructionTime).format('YYYY-MM-DD') }}
        </template>
      </el-table-column>
      <el-table-column align="center" property="updateTime" label="更新时间">
        <template #default="scope">
          {{ dayjs(scope.row.updateTime).format('YYYY-MM-DD') }}
        </template>
      </el-table-column>
      <el-table-column align="center" label="操作">
        <template #default="scope">
          <el-button link @click="onEdit(scope.row)">修改</el-button>
          <el-button link @click="onDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div style="margin-top: 20px">
      <el-button @click="toggleSelection()">清空选择</el-button>
      <div class="example-pagination-block">
        <el-pagination layout="prev, pager, next" :total="buildingPage?.total" @size-change="handleSizeChange"
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
