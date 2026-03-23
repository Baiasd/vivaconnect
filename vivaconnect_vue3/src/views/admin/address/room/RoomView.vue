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

interface Room {
  rid: number
  roomNumber: string
  status: boolean
  saleTime: Date | string
  ownerId: number
  updateTime: Date | string
  remark: string
}

interface RoomPage {
  records: Room[]
  total: number
  size: number
  current: number
  pages: number
}

const multipleTableRef = ref<TableInstance>()
const multipleSelection = ref<Room[]>([])
const roomPage = ref<RoomPage>() // 存储从API获取的数据
const areaList = ref<Area[]>([]) // 存储从API获取的数据
const area = reactive({aid: 1} as Area) // 存储从API获取的数据
const buildingList = ref<Building[]>([]) // 存储从API获取的数据
const building = reactive({} as Building) // 存储从API获取的数据

const toggleSelection = (rows?: Room[], ignoreSelectable?: boolean) => {
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
const handleSelectionChange = (val: Room[]) => {
  multipleSelection.value = val
}

const loadAreaList = async () => {
  areaList.value = await (await axios.get('/api/address/area/findAreaList')).data
  console.log("区域列表：", areaList.value)
}

const loadBuildingList = async () => {
  buildingList.value = await (await axios.get('/api/address/building/findBuildingList')).data
  console.log("楼宇列表：", buildingList.value)
  Object.assign(building, buildingList.value?.[0])
}

const loadRoomPage = async () => {
  roomPage.value = await (await axios.get('/api/address/room/findRoomPageByBid', {
    params: {
      bid: building.bid,
    }
  })).data
  console.log("房间列表：", roomPage.value)
}

onMounted(async () => {
  await loadAreaList()
  await loadBuildingList()
  await loadRoomPage()
})


// 新增管理用户
const onAdd = () => {
  router.push({path: '/user/address/room/add'})
}

const onEdit = (row: Room) => {
  router.push({
    name: 'EditRoom',
    params: {
      rid: row.rid,
      bid: building.bid
    }
  })
}

const onDelete = (row: Room) => {
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
      await axios.delete(`/api/address/room/removeById`, {
        params: {
          rid: row.rid
        }
      })

      // 3. 删除成功提示（网页6）
      ElMessage.success('删除成功')

      // 4. 刷新数据列表（网页4）
      await loadRoomPage()

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

  axios.get('/api/address/room/findRoomPageByBid', {
    params: {
      page: val,
      bid: building.bid
    }
  }).then(data => {
    roomPage.value = data.data;
    console.log(roomPage.value)
  })
}

</script>

<template>
  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是住房管理页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled type="info">地址管理></el-link>
        <el-link disabled type="info">住房管理</el-link>
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
            @change="loadBuildingList"
        >
          <el-option
              v-for="item in areaList"
              :key="item.aid"
              :label="item.areaName"
              :value="item.aid"
          />
        </el-select>
      </el-col>
      <el-col :span="4">
        <div class="grid-content ep-bg-purple-light"/>
        <el-select
            v-model="building.bid"
            placeholder="Select"
            size="large"
            style="width: 100%"
            @change="loadRoomPage"
        >
          <el-option
              v-for="item in buildingList"
              :key="item.bid"
              :label="item.buildingName"
              :value="item.bid"
          />
        </el-select>
      </el-col>
    </el-row>

    <el-table
        ref="multipleTableRef"
        :data="roomPage?.records"
        row-key="rid"
        style="width: 100%"
        @selection-change="handleSelectionChange"
    >
      <el-table-column align="center" type="selection" width="55"/>
      <el-table-column align="center" property="roomNumber" label="房号" width="120"/>
      <el-table-column align="center" property="status" label="是否已售出" width="120">
        <template #default="scope">
          <span v-if="scope.row.status == 1">是</span>
          <span v-if="scope.row.status == 0">否</span>
        </template>
      </el-table-column>
      <el-table-column align="center" property="ownerId" label="所有者ID"/>
      <el-table-column align="center" property="saleTime" label="售出时间">
        <template #default="scope">
          {{ dayjs(scope.row.saleTime).format('YYYY-MM-DD') }}
        </template>
      </el-table-column>
      <el-table-column align="center" property="updateTime" label="更新时间">
        <template #default="scope">
          {{ dayjs(scope.row.updateTime).format('YYYY-MM-DD') }}
        </template>
      </el-table-column>
      <el-table-column property="remark" label="备注信息"/>
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
        <el-pagination layout="prev, pager, next" :total="roomPage?.total" @size-change="handleSizeChange"
                       @current-change="handleCurrentChange"/>
      </div>
    </div>
  </el-card>

</template>


<style scoped>

</style>
