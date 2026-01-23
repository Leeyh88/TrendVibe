<?php

namespace App\Policies;

use App\Models\User;

class UserPolicy
{
    /**
     * 관리자라면 유저 목록을 볼 수 있게 합니다.
     */
    public function viewAny(User $user): bool
    {
        return $user->is_admin;
    }

    /**
     * 관리자라면 유저 상세 정보를 볼 수 있게 합니다.
     */
    public function view(User $user, User $model): bool
    {
        return $user->is_admin;
    }

    /**
     * 새로운 유저 생성을 허용합니다. (필요 없으면 false)
     */
    public function create(User $user): bool
    {
        return false;
    }

    /**
     * 유저 정보 수정을 허용합니다.
     */
    public function update(User $user, User $model): bool
    {
        return $user->is_admin;
    }

    /**
     * ❌ 삭제는 아무도 할 수 없게 막습니다.
     * 이 설정만 false로 두면 상세 페이지와 목록에서 삭제 버튼이 사라집니다.
     */
    public function delete(User $user, User $model): bool
    {
        return false;
    }

    /**
     * 일괄 삭제도 막습니다.
     */
    public function deleteAny(User $user): bool
    {
        return false;
    }

    // 나머지는 기본값 false 유지 (복구 및 영구삭제 방지)
    public function restore(User $user, User $model): bool { return false; }
    public function forceDelete(User $user, User $model): bool { return false; }
}