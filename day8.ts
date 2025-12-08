import * as fs from "fs";

type P = { x: number; y: number; z: number };

const pts: P[] = fs.readFileSync("input8.txt", "utf8")
    .trim()
    .split("\n")
    .map(l => {
        const [x, y, z] = l.split(",").map(Number);
        return { x, y, z };
    });

const n = pts.length;

function d2(a: P, b: P): number {
    const dx = a.x - b.x;
    const dy = a.y - b.y;
    const dz = a.z - b.z;
    return dx*dx + dy*dy + dz*dz;
}

class DSU {
    parent: number[];
    size: number[];
    count: number;
    constructor(n: number) {
        this.parent = [];
        this.size = [];
        this.count = n;
        for (let i = 0; i < n; i++) {
            this.parent[i] = i;
            this.size[i] = 1;
        }
    }
    find(a: number): number {
        while (this.parent[a] !== a) {
            this.parent[a] = this.parent[this.parent[a]];
            a = this.parent[a];
        }
        return a;
    }
    union(a: number, b: number): boolean {
        let ra = this.find(a);
        let rb = this.find(b);
        if (ra === rb) return false;
        if (this.size[ra] < this.size[rb]) {
            this.parent[ra] = rb;
            this.size[rb] += this.size[ra];
        } else {
            this.parent[rb] = ra;
            this.size[ra] += this.size[rb];
        }
        this.count--;
        return true;
    }
}

let edges: { i: number; j: number; w: number }[] = [];

for (let i = 0; i < n; i++) {
    for (let j = i + 1; j < n; j++) {
        edges.push({ i, j, w: d2(pts[i], pts[j]) });
    }
}

edges.sort((a, b) => a.w - b.w);

let dsu = new DSU(n);
let lastI = -1;
let lastJ = -1;
let attempt = 0;

for (let e of edges) {
    if (attempt < 1000) {
        dsu.union(e.i, e.j);
        attempt++;
        continue;
    }
    if (dsu.union(e.i, e.j)) {
        lastI = e.i;
        lastJ = e.j;
        if (dsu.count === 1) break;
    }
}

console.log("  answer lmfao :");
console.log(pts[lastI].x * pts[lastJ].x);
