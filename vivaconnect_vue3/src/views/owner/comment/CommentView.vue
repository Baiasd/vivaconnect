<script lang="ts" setup>
import {useRoute, useRouter} from 'vue-router'
import {onBeforeUnmount, onMounted, reactive, ref, shallowRef} from 'vue'
import axios from "@/utils/axios";
import {ArrowLeft} from "@element-plus/icons-vue";
import '@wangeditor/editor/dist/css/style.css'
import {Editor, Toolbar} from '@wangeditor/editor-for-vue'

interface Comment {
  cid: number
  ownerId: number
  rating: number
  content: string
  commentTime: Date | string
  createTime: Date | string
  replyContent: string
  replyTime: Date | string
}

const route = useRoute()
const router = useRouter()

const cid = Number(route.params.cid)
const uid = Number(route.params.uid)
const comment = reactive({} as Comment)

const loadComment = async () => {
  const commentData = (await axios.get('/api/repair/comment/findComment', {
    params: {cid: cid}
  })).data
  Object.assign(comment, commentData)
  console.log(comment)
}

onMounted(async () => {
  await loadComment()
})


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
  comment.ownerId = uid
  comment.commentTime = new Date()
  console.log(comment)
  axios.put(`/api/repair/comment/updateComment`, comment).then(data => {
    console.log(data)
  })
}

const goBack = () => {
  router.back();
}
</script>

<template>

  <el-button :icon="ArrowLeft" @click="goBack">返回</el-button>

  <el-row class="row-bg" justify="space-around" align="middle">
    <el-col :span="20">
      <div class="grid-content ep-bg-purple">
        <h1>这是评价页面</h1>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content ep-bg-purple-light">
        <el-link disabled>订单></el-link>
        <el-link href="/#/owner/repair" type="info">报修></el-link>
        <el-link disabled>评价</el-link>
      </div>
    </el-col>
  </el-row>

  <el-form v-if="comment.commentTime === null" :model="comment" label-width="auto">
    <el-descriptions title="通知详情" :column="1" border>
      <el-descriptions-item align="center" label="评分">
        <el-form-item>
          <el-rate v-model="comment.rating" allow-half clearable :colors="['#99A9BF', '#F7BA2A', '#FF9900']"/>
        </el-form-item>
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
              v-model="comment.content"
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
  <span v-else>您已评价</span>
</template>

<style scoped>
</style>