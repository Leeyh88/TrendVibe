<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use App\Models\User;
use App\Models\Remix;

class AdminAccessTest extends TestCase
{
    /**
     * A basic feature test example.
     */
    public function test_example(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200);
    }

    public function test_유저는_리믹스에_투표할_수_있다()
    {
        $user = User::factory()->create();
        $remix = Remix::factory()->create(['vote_count' => 0]);

        // 유저가 투표 API를 호출했을 때
        $response = $this->actingAs($user)->postJson("/api/remixes/{$remix->id}/vote");

        // 1. 성공 응답이 오는지 확인
        $response->assertStatus(200);
        // 2. DB의 vote_count가 1이 되었는지 확인
        $this->assertEquals(1, $remix->refresh()->vote_count);
    }
}
