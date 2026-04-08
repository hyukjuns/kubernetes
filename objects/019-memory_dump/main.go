package main

import (
	"fmt"
	"time"
)

func main() {
	var blocks [][]byte
	var mbAllocated int

	for {
		// 10MB씩 계속 할당
		b := make([]byte, 10*1024*1024)

		// 실제로 페이지를 touch 해서 RSS/WS가 올라가게 함 (lazy allocation 방지)
		for i := 0; i < len(b); i += 4096 {
			b[i] = 1
		}

		blocks = append(blocks, b)
		mbAllocated += 10

		fmt.Printf("allocated=%dMB blocks=%d\n", mbAllocated, len(blocks))
		time.Sleep(500 * time.Millisecond)
	}
}
