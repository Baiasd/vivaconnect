<script lang="ts" setup>
import {House, User} from "@element-plus/icons-vue";

const handleOpen = (key: string, keyPath: string[]) => {
  console.log(key, keyPath)
}
const handleClose = (key: string, keyPath: string[]) => {
  console.log(key, keyPath)
}
</script>

<template>
  <el-menu
      v-role="'管理员'"
      :router="true"
      default-active="2"
      class="el-menu-vertical-demo"
      @open="handleOpen"
      @close="handleClose"
  >
    <el-menu-item index="/user">
      <el-icon>
        <House/>
      </el-icon>
      <span>首页</span>
    </el-menu-item>
    <el-sub-menu>
      <template #title>
        <el-icon>
          <User/>
        </el-icon>
        <span>用户管理</span>
      </template>
      <el-menu-item index="/user/admin" v-permission="'/user/findAdminPage'">管理员管理</el-menu-item>
      <el-menu-item index="/user/owner" v-permission="'/user/findOwnerPage'">业主管理</el-menu-item>
      <el-menu-item index="/user/maintainer" v-permission="'/user/findMaintainerPage'">维修工管理</el-menu-item>
      <el-menu-item index="/user/role" v-permission="'/role/findRolePage'">角色管理</el-menu-item>
      <el-menu-item index="/user/permission" v-permission="'/permission/findPermissionPage'">权限管理</el-menu-item>
    </el-sub-menu>

    <el-sub-menu index="/user/repair">
      <template #title>
        <el-icon>
          <User/>
        </el-icon>
        <span>报修管理</span>
      </template>
      <el-menu-item index="/user/repair/order" v-permission="'/repairOrder/findAllRepairOrderPage'">工单管理</el-menu-item>
      <el-menu-item index="/user/repair/faultType" v-permission="'/faultType/findFaultTypePage'">故障类型管理</el-menu-item>
      <el-menu-item index="/user/repair/jobType" v-permission="'/jobType/findPage'">工种管理</el-menu-item>
    </el-sub-menu>

    <el-sub-menu index="/user/notice">
      <template #title>
        <el-icon>
          <User/>
        </el-icon>
        <span>通知管理</span>
      </template>
      <el-menu-item index="/user/notice">通知管理</el-menu-item>
    </el-sub-menu>

    <el-sub-menu index="/user/address">
      <template #title>
        <el-icon>
          <User/>
        </el-icon>
        <span>地址管理</span>
      </template>
      <el-menu-item index="/user/address/area" v-permission="'/area/findAreaPage'">区域管理</el-menu-item>
      <el-menu-item index="/user/address/building" v-permission="'/building/findBuildingPageByAid'">楼宇管理</el-menu-item>
      <el-menu-item index="/user/address/room" v-permission="'/room/findRoomPageByBid'">住房管理</el-menu-item>
    </el-sub-menu>
  </el-menu>
  <el-menu
      v-role="'业主'"
      :router="true"
      default-active="2"
      class="el-menu-vertical-demo"
      @open="handleOpen"
      @close="handleClose"
  >
    <el-menu-item index="/owner">
      <el-icon>
        <House/>
      </el-icon>
      <span>首页</span>
    </el-menu-item>
    <el-sub-menu>
      <template #title>
        <el-icon>
          <User/>
        </el-icon>
        <span>个人信息</span>
      </template>
      <el-menu-item index="/owner/message">个人信息</el-menu-item>
    </el-sub-menu>

    <el-sub-menu index="/owner/repair">
      <template #title>
        <el-icon>
          <User/>
        </el-icon>
        <span>报修</span>
      </template>
      <el-menu-item index="/owner/repair/order">订单记录</el-menu-item>
    </el-sub-menu>
  </el-menu>
  <el-menu
      v-role="'维修工'"
      :router="true"
      default-active="2"
      class="el-menu-vertical-demo"
      @open="handleOpen"
      @close="handleClose"
  >
    <el-menu-item index="/maintainer">
      <el-icon>
        <House/>
      </el-icon>
      <span>首页</span>
    </el-menu-item>
    <el-sub-menu>
      <template #title>
        <el-icon>
          <User/>
        </el-icon>
        <span>个人信息</span>
      </template>
      <el-menu-item index="/maintainer/message">个人信息</el-menu-item>
    </el-sub-menu>

    <el-sub-menu index="/maintainer/repair">
      <template #title>
        <el-icon>
          <User/>
        </el-icon>
        <span>报修</span>
      </template>
      <el-menu-item index="/maintainer/repair/order">接单</el-menu-item>
      <el-menu-item index="/maintainer/repair/takenOrder">订单记录</el-menu-item>
    </el-sub-menu>
  </el-menu>
</template>
<style scoped>

</style>