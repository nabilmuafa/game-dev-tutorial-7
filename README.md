# Tutorial 7 Game Development

## Latihan Mandiri

Untuk latihan mandiri tutorial ini, saya hanya mengimplementasikan Sprinting dan Crouching. Sebelum implementasi dua hal ini, saya sedikit memoles script movement dari player. Menggunakan script yang ada di tutorial, movementnya terasa terlalu smooth dan tidak terlalu FPS-like, sehingga ada beberapa hal yang saya adjust:

- Menambahkan head bob  
  Head bob adalah movement kepala yang terlihat ketika player berjalan/berlari. Untuk mengimplementasikan ini, saya membuat helper function yang didalamnya menghitung koordinat-koordinat baru untuk kamera menggunakan fungsi trigonometri berdasarkan konstanta pergerakan kepala.

      ```
      t_bob += delta * velocity.length() * float(is_on_floor())
          var bob_offset = _headbob(t_bob)
          camera.transform.origin = bob_offset

          move_and_slide()

      func _headbob(time) -> Vector3:
          var pos = Vector3.ZERO
          pos.y = sin(time * BOB_FREQ) * BOB_AMP
          pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
          return pos
      ```

- Movement menggunakan sistem direction  
  Pada tutorial, movement vector menyimpan basis dari arah yang ditekan player, kemudian movement vector di-normalize dan ditambahkan secara langsung ke velocity. Untuk meningkatkan readability, saya menggunakan `Input.get_vector()` yang diisi dengan empat arah yang bisa ditekan player. Dari direction ini, baru dihitung normalized movement vector yang juga dihitung menggunakan basis node Head. Selain itu, agar lebih akurat dengan fisika, linear interpolation (lerp) untuk menghentikan movement hanya diaplikasikan jika player sedang berada di udara. Apabila player ada di daratan dan berhenti bergerak, lerp yang diimplementasikan menggunakan faktor acceleration yang tinggi sehingga terdapat smoothness ketika player berhenti bergerak, tetapi tidak sebanyak yang ada di tutorial.

  ```
  var input_dir = Input.get_vector("movement_left", "movement_right", "movement_forward", "movement_backward")
      var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
      if is_on_floor():
          if direction:
              velocity.x = direction.x * speed
              velocity.z = direction.z * speed
          else:
              velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
              velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
      else:
          velocity.x = lerp(velocity.x, direction.x * speed, delta * acceleration)
          velocity.z = lerp(velocity.z, direction.z * speed, delta * acceleration)
  ```

### Sprinting

Untuk mengimplementasikan sprint, saya mendefinisikan speed baru, yaitu sprint speed. Speed asli juga saya kurangi, tetapi menjadi setengahnya dari sprint speed. Kemudian, di dalam `_physics_process` dilakukan pengecekan apakah tombol sprint (yang saya assign dengan `Shift`) sedang ditekan. Apabila iya, maka ubah speed player menjadi sprint speed, dan berlaku juga sebaliknya.

```
@export var speed: float
...
const WALK_SPEED = 8.0
const SPRINT_SPEED = 16.0
...
if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
else:
		speed = WALK_SPEED
...
# kode di atas
if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
            ...

```

### Crouching

Untuk mengimplementasikan crouch, saya mendefinisikan speed baru lagi, yaitu crouching speed yang nilainya setengah dari walk speed. Untuk memberikan efek menunduk ketika crouch, saya juga mengimplementasikan camera height berbeda untuk crouch dan untuk berdiri (jalan/lari). Untuk mengubah camera height, saya lakukan ini pada helper function yang menghitung head bob dengan menyimpan state camera height dan memeriksa apakah state saat ini sama dengan state crouch. Jika iya, maka kamera akan diturunkan pada sumbu Y. Hal ini perlu dilakukan di dalam helper function head bob karena jika tidak, turunnya camera height bisa di-override oleh head bob itu sendiri.

```
@export var crouch_height: float = -0.5
@export var standing_height: float = 0.0
...
var target_camera_height: float = 0.0
...
const CROUCH_SPEED = 4.0
const WALK_SPEED = 8.0
...
if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
		target_camera_height = standing_height
	elif Input.is_action_pressed("crouch"):
		speed = CROUCH_SPEED
		target_camera_height = crouch_height
	else:
		speed = WALK_SPEED
		target_camera_height = standing_height
...
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	if target_camera_height == crouch_height:
		pos.y -= 0.5
	return pos
```

## Bonus (Dari Saya, Bukan Task Tutorial)

Saya iseng implement SFX vine boom kalau playernya kalah, supaya ada jenakanya sedikit. Win screen saya (gambar Keanu Reeves) juga sengaja saya stretch agar ada jenakanya sedikit.

## Referensi

[Juiced Up First Person Character Controller Tutorial - Godot 3D FPS (YouTube)
](https://www.youtube.com/watch?v=A3HLeyaBCq4)
