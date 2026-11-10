<?php

namespace Tests\Feature;

use App\Models\Task;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TaskApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_health_endpoint_is_ok(): void
    {
        $this->getJson('/api/health')->assertOk()->assertJson(['status' => 'ok', 'db' => 'up']);
    }

    public function test_can_create_and_list_tasks(): void
    {
        $this->postJson('/api/tasks', ['title' => 'Learn Jenkins'])
            ->assertCreated()->assertJsonPath('title', 'Learn Jenkins');

        $this->getJson('/api/tasks')->assertOk()->assertJsonCount(1);
    }

    public function test_title_is_required(): void
    {
        $this->postJson('/api/tasks', [])->assertStatus(422)->assertJsonValidationErrors('title');
    }

    public function test_can_toggle_and_delete(): void
    {
        $task = Task::factory()->create();

        $this->putJson("/api/tasks/{$task->id}", ['done' => true])->assertOk()->assertJsonPath('done', true);
        $this->deleteJson("/api/tasks/{$task->id}")->assertNoContent();
        $this->assertDatabaseCount('tasks', 0);
    }
}
