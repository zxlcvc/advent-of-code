using System;
using System.Collections.Generic;
using System.IO;

class P
{
    static void Main()
    {
        var lines = File.ReadAllLines(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "input6.txt"));
        if (lines.Length == 0)
        {
            Console.WriteLine(0);
            return;
        }

        int h = lines.Length;
        int w = 0;
        foreach (var ln in lines)
            if (ln.Length > w) w = ln.Length;

        var g = new char[h, w];
        for (int y = 0; y < h; y++)
        {
            var ln = lines[y];
            for (int x = 0; x < w; x++)
                g[y, x] = x < ln.Length ? ln[x] : ' ';
        }

        long ans = 0;
        int x0 = 0;

        while (x0 < w)
        {
            while (x0 < w && EmptyCol(g, h, x0)) x0++;
            if (x0 >= w) break;

            int x1 = x0;
            while (x1 + 1 < w && !EmptyCol(g, h, x1 + 1)) x1++;

            var nums = new List<long>();
            for (int y = 0; y < h - 1; y++)
            {
                var s = "";
                for (int x = x0; x <= x1; x++)
                    s += g[y, x];
                s = s.Trim();
                if (s.Length > 0)
                    nums.Add(long.Parse(s));
            }

            char op = '+';
            for (int x = x0; x <= x1; x++)
            {
                var c = g[h - 1, x];
                if (c == '+' || c == '*')
                {
                    op = c;
                    break;
                }
            }

            long v = nums[0];
            for (int i = 1; i < nums.Count; i++)
                v = op == '+' ? v + nums[i] : v * nums[i];

            ans += v;
            x0 = x1 + 1;
        }

        Console.WriteLine(ans);

        long ans2 = 0;
        x0 = 0;

        while (x0 < w)
        {
            while (x0 < w && EmptyCol(g, h, x0)) x0++;
            if (x0 >= w) break;

            int x1 = x0;
            while (x1 + 1 < w && !EmptyCol(g, h, x1 + 1)) x1++;

            char op = '+';
            for (int x = x0; x <= x1; x++)
            {
                var c = g[h - 1, x];
                if (c == '+' || c == '*')
                {
                    op = c;
                    break;
                }
            }

            var nums = new List<long>();
            for (int x = x1; x >= x0; x--)
            {
                string s = "";
                for (int y = 0; y < h - 1; y++)
                {
                    var c = g[y, x];
                    if (char.IsDigit(c)) s += c;
                }
                if (s.Length > 0)
                    nums.Add(long.Parse(s));
            }

            long v = nums[0];
            for (int i = 1; i < nums.Count; i++)
                v = op == '+' ? v + nums[i] : v * nums[i];

            ans2 += v;

            x0 = x1 + 1;
        }

        Console.WriteLine(ans2);
    }

    static bool EmptyCol(char[,] g, int h, int x)
    {
        for (int y = 0; y < h; y++)
            if (g[y, x] != ' ') return false;
        return true;
    }
}
