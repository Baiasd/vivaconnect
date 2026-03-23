<script lang="ts" setup>
import {useRoute, useRouter} from 'vue-router'
import {onBeforeUnmount, onMounted, reactive, ref, shallowRef} from 'vue'
import axios from "@/utils/axios";
import {ArrowLeft} from "@element-plus/icons-vue";
import '@wangeditor/editor/dist/css/style.css'
import {Editor, Toolbar} from '@wangeditor/editor-for-vue'
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
const notice = reactive({} as Notice)

const loadNotice = async () => {
  const noticeData = (await axios.get('/api/notice/getById', {
    params: {nid: nid}
  })).data
  Object.assign(notice, noticeData)
  console.log(notice)
}

onMounted(async () => {
  await loadNotice()
})


const goBack = () => {
  router.back();
}


const editorRef = shallowRef()
const editorContainer = ref(null)

const toolbarConfig = {}
const editorConfig = {
  placeholder: '请输入内容...',
  MENU_CONF: {
    uploadImage: {
      server: '/api/file/uploadFile', // 替换为实际接口
      fieldName: 'file',
      maxFileSize: 10 * 1024 * 1024, // 10MB
      allowedFileTypes: ['image/*'],
      customInsert(res, insertFn) {
        if (res.code === 200) {
          insertFn(res.data)
        }
      }
    }
  }
}

// 组件销毁时，也及时销毁编辑器
onBeforeUnmount(() => {
  const editor = editorRef.value
  if (editor == null) return
  editor.destroy()
})

const handleCreated = (editor) => {
  editorRef.value = editor
}

const onSubmit = () => {
  console.log('submit!')
  console.log(notice)
  axios.put(`/api/notice/updateById`, notice).then(data => {
    console.log(data)
  })
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

  <el-form :model="notice" label-width="auto">
    <el-descriptions title="通知详情" :column="4" border>
      <el-descriptions-item align="center" label="管理员id">
        <el-form-item>
          {{ notice.adminId }}
        </el-form-item>
      </el-descriptions-item>
      <el-descriptions-item align="center" label="标题">
        <el-form-item style="margin-bottom: 0">
          <el-input v-model="notice.title" size="large"/>
        </el-form-item>
      </el-descriptions-item>
      <el-descriptions-item align="center" label="创建时间">{{
          dayjs(notice?.createTime).format('YYYY-MM-DD HH:mm:ss')
        }}
      </el-descriptions-item>
      <el-descriptions-item align="center" label="发布时间">{{
          dayjs(notice?.publishTime).format('YYYY-MM-DD HH:mm:ss')
        }}
      </el-descriptions-item>
      <el-descriptions-item align="center" label="详情">
        <div ref="editorContainer" style="border: 1px solid #e5e7eb; border-radius: 4px">
          <Toolbar
              :editor="editorRef"
              :defaultConfig="toolbarConfig"
              mode="default"
              style="border-bottom: 1px solid #e5e7eb"
          />
          <Editor
              v-model="notice.content"
              :defaultConfig="editorConfig"
              mode="default"
              @onCreated="handleCreated"
              style="height: 400px; overflow-y: hidden"
          />
        </div>
      </el-descriptions-item>
    </el-descriptions>
    <el-form-item>
      <el-button type="primary" @click="onSubmit">提交</el-button>
      <el-button>重置</el-button>
    </el-form-item>
  </el-form>
</template>

<style scoped>
</style>