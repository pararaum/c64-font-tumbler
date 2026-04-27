<template>
  <div class="container">
    <!-- Main 16x16 grid -->
    <div class="grid-container">
      <div
        v-for="(cell, index) in grid"
        :key="index"
        class="grid-cell"
        :class="{ 'selected': index === currentCellIndex }"
        @click="setCurrentCell(index)"
      >
        <div
          v-for="(pixel, i) in cell"
          :key="i"
          class="pixel"
          :style="{ backgroundColor: pixel ? 'black' : 'white' }"
        ></div>
      </div>
    </div>

    <!-- Persistent 8x8 pixel editor -->
    <div class="editor-container">
      <h3>Edit Cell {{ currentCellIndex + 1 }}</h3>
      <div class="pixel-editor">
        <div
          v-for="(pixel, i) in currentCell"
          :key="i"
          class="editor-pixel"
          :style="{ backgroundColor: pixel ? 'black' : 'white' }"
          @click="togglePixel(i)"
        ></div>
      </div>

      <!-- Transformation controls -->
      <div class="transformations-frame">
        <h4>Transformations</h4>
        <div class="transformation" v-for="(transform, key) in applyAll" :key="key">
          <label>
            <input type="checkbox" v-model="applyAll[key]">
            Apply to all
          </label>
          <button @click="applyTransformation(key)">{{ transformNames[key] }}</button>
        </div>
      </div>

      <!-- Tumble Font controls -->
      <div class="tumble-frame">
        <h4>Tumble Font</h4>
        <button @click="tumbleFont">Tumble Font</button>
      </div>

      <!-- File upload button -->
      <input
        type="file"
        ref="fileInput"
        @change="handleFileUpload"
        accept=".64c"
      />
      <button @click="$refs.fileInput.click()">Upload Binary File</button>
      <!-- Download button -->
      <button @click="downloadBinaryFile">Download Binary File</button>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      grid: Array(16 * 16).fill().map(() => Array(64).fill(false)),
      currentCellIndex: 0,
      applyAll: {
        rotateClockwise: false,
        rotateCounterClockwise: false,
        flipHorizontally: false,
        flipVertically: false,
        invertColors: false,
      },
      transformNames: {
        rotateClockwise: "Rotate 90° Clockwise",
        rotateCounterClockwise: "Rotate 90° Counter-Clockwise",
        flipHorizontally: "Flip Horizontally",
        flipVertically: "Flip Vertically",
        invertColors: "Invert Colors",
      },
    };
  },
  computed: {
    currentCell() {
      return this.grid[this.currentCellIndex];
    },
  },
  methods: {
    setCurrentCell(index) {
      this.currentCellIndex = index;
    },
    togglePixel(i) {
      const newCell = [...this.grid[this.currentCellIndex]];
      newCell[i] = !newCell[i];
      this.grid[this.currentCellIndex] = newCell;
    },
    // Apply transformation to current cell or all cells
    applyTransformation(transformFn) {
      if (this.applyAll[transformFn]) {
        this.grid = this.grid.map((cell) => {
          return this[transformFn](cell, true);
        });
      } else {
        const newCell = this[transformFn](this.currentCell, true);
        this.grid[this.currentCellIndex] = newCell;
      }
    },
    // Transformations
    rotateCounterClockwise(cell, internalCall) {
      if (!internalCall) return;
      const newCell = Array(64).fill(false);
      for (let y = 0; y < 8; y++) {
        for (let x = 0; x < 8; x++) {
          const newX = y;
          const newY = 7 - x;
          newCell[newY * 8 + newX] = cell[y * 8 + x];
        }
      }
      return newCell;
    },
    rotateClockwise(cell, internalCall) {
      if (!internalCall) return;
      const newCell = Array(64).fill(false);
      for (let y = 0; y < 8; y++) {
        for (let x = 0; x < 8; x++) {
          const newX = 7 - y;
          const newY = x;
          newCell[newY * 8 + newX] = cell[y * 8 + x];
        }
      }
      return newCell;
    },
    rotate180(cell, internalCall) {
      if (!internalCall) return;
      const newCell = Array(64).fill(false);
      for (let y = 0; y < 8; y++) {
        for (let x = 0; x < 8; x++) {
          const newX = 7 - x;
          const newY = 7 - y;
          newCell[newY * 8 + newX] = cell[y * 8 + x];
        }
      }
      return newCell;
    },
    rotate270(cell, internalCall) {
      if (!internalCall) return;
      const newCell = Array(64).fill(false);
      for (let y = 0; y < 8; y++) {
        for (let x = 0; x < 8; x++) {
          const newX = 7 - x;
          const newY = y;
          newCell[newY * 8 + newX] = cell[x * 8 + (7 - y)];
        }
      }
      return newCell;
    },
    flipHorizontally(cell, internalCall) {
      if (!internalCall) return;
      const newCell = [...cell];
      for (let y = 0; y < 8; y++) {
        for (let x = 0; x < 4; x++) {
          const left = y * 8 + x;
          const right = y * 8 + (7 - x);
          [newCell[left], newCell[right]] = [newCell[right], newCell[left]];
        }
      }
      return newCell;
    },
    flipVertically(cell, internalCall) {
      if (!internalCall) return;
      const newCell = [...cell];
      for (let y = 0; y < 4; y++) {
        for (let x = 0; x < 8; x++) {
          const top = y * 8 + x;
          const bottom = (7 - y) * 8 + x;
          [newCell[top], newCell[bottom]] = [newCell[bottom], newCell[top]];
        }
      }
      return newCell;
    },
    invertColors(cell, internalCall) {
      if (!internalCall) return;
      return cell.map(pixel => !pixel);
    },
    // Tumble Font: Apply rotations to blocks 64-255
      tumbleFont() {
          // Copy first 64 blocks to 64-127 (90° CCW)
          for (let i = 0; i < 64; i++) {
              this.grid[64 + i] = this.rotateCounterClockwise(this.grid[i], true);
          }
          // Copy first 64 blocks to 128-195 (180°)
          for (let i = 0; i < 64; i++) {
              this.grid[128 + i] = this.rotate180(this.grid[i], true);
          }
          // Copy first 64 blocks to 196-255 (270° CCW)
          for (let i = 0; i < 64; i++) {
              this.grid[192 + i] = this.rotate270(this.grid[i], true);
          }
      },
    // File handling
    handleFileUpload(event) {
      const file = event.target.files[0];
      if (!file) return;

      const reader = new FileReader();
      reader.onload = (e) => {
        const buffer = new Uint8Array(e.target.result);
        if (buffer.length !== 2050) {
          alert("File must be exactly 2050 bytes long.");
          return;
        }

        // Skip the first 2 bytes
        const pixelData = buffer.subarray(2, 2050);

        // Update the grid with the pixel data
        for (let blockIndex = 0; blockIndex < 256; blockIndex++) {
            const block = Array(64).fill(false);
            for (let row = 0; row < 8; ++row) {
                const byte = pixelData[blockIndex*8 + row];
                for (let bit = 0; bit < 8; bit++) {
                    const isSet = (byte >> (7 - bit)) & 1;
                    const pixelIndex = row * 8 + bit;
                    block[pixelIndex] = !!isSet;
                }
            }
          this.grid[blockIndex] = block;
        }
      };
      reader.readAsArrayBuffer(file);
    },
    downloadBinaryFile() {
      const binaryData = new Uint8Array(2050);
      binaryData[0] = 0x00;
      binaryData[1] = 0x38;

      for (let blockIndex = 0; blockIndex < 256; blockIndex++) {
        const block = this.grid[blockIndex];
        for (let row = 0; row < 8; row++) {
          let byte = 0;
          for (let bit = 0; bit < 8; bit++) {
            const pixelIndex = row * 8 + bit;
            const isSet = block[pixelIndex] ? 1 : 0;
            byte = (byte << 1) | isSet;
          }
          binaryData[2 + blockIndex * 8 + row] = byte;
        }
      }

      const blob = new Blob([binaryData], { type: 'application/octet-stream' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'grid_data.64c';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    },
  },
};
</script>

<style scoped>
.container {
  display: flex;
  gap: 20px;
  padding: 20px;
}
.grid-container {
  display: grid;
  grid-template-columns: repeat(16, 64px);
  grid-template-rows: repeat(16, 64px);
  gap: 1px;
  border: 1px solid #ccc;
}
.grid-cell {
  display: grid;
  grid-template-columns: repeat(8, 8px);
  grid-template-rows: repeat(8, 8px);
  gap: 0;
  cursor: pointer;
  border: 1px solid #eee;
}
.grid-cell.selected {
  border: 2px solid red;
}
.pixel {
  border: 0.5px solid #f0f0f0;
}
.editor-container {
  width: 200px;
}
.pixel-editor {
  display: grid;
  grid-template-columns: repeat(8, 20px);
  grid-template-rows: repeat(8, 20px);
  gap: 1px;
  background: white;
  border: 1px solid #ccc;
  margin-bottom: 10px;
}
.editor-pixel {
  cursor: pointer;
  border: 1px solid #eee;
}
.transformations-frame, .tumble-frame {
  border: 1px solid #ccc;
  padding: 10px;
  margin-bottom: 10px;
  border-radius: 5px;
}
.transformations-frame h4, .tumble-frame h4 {
  margin-top: 0;
  margin-bottom: 10px;
}
.transformation {
  margin-bottom: 8px;
}
.transformation label {
  display: inline-flex;
  align-items: center;
  margin-right: 8px;
  font-size: 12px;
}
.transformation input[type="checkbox"] {
  margin-right: 5px;
}
.transformation button, .tumble-frame button {
  width: 100%;
  margin-top: 3px;
}
</style>
