import { useAuthStore } from '@/stores/auth'

export const userPermission = () => {
    const { permissions } = useAuthStore()

    const hasPermission = (value: string | string[]) => {
        if (Array.isArray(value)) {
            return value.some(perm => permissions.includes(perm))
        }
        return permissions.includes(value)
    }

    return { hasPermission }
}