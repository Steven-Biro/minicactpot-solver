from multiprocessing import Pool, freeze_support
import cProfile
import io
import pstats
import os
from pstats import SortKey
import numpy as np
import random
from main import ChooseNumber,PickRow


pr = cProfile.Profile()
rewards = np.array([10000, 36, 720, 360, 80, 252, 108, 72, 54, 180, 72, 180, 119, 36, 306, 1080, 144, 1800, 3600])
pos_ans = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]



def GenRandBoard():
    return [int(i) for i in 1 + np.random.permutation(9)]


def GetSliceReward(cells, board):
    list.sort(cells)
    if not cells in pos_ans:
        print("Wow, what a cheater")
        exit()
    tot = 0
    for c in cells:
        tot += board[c - 1]
    return rewards[tot - 6]


def PlayGame(vars):
    true_board,CellFx,FinalFx = vars[0],vars[1],vars[2]
    known_board = ['-'] * 9
    rev = random.randint(0, 8)
    known_board[rev] = true_board[rev]
    # do 3 rounds of cell selection
    for i in range(3):
        k = CellFx(known_board)
        if type(k) != type(3) or not k in true_board:
            print("Invalid Cell Selection!")
            exit()
        if type(known_board[k - 1]) == type(3):
            print("Double Cell selection!")
            exit()
        known_board[k - 1] = true_board[k - 1]
    # then select the row / column / diagonal
    cells = FinalFx(known_board)
    return GetSliceReward(cells, true_board)



def main(games):
    true_boards = list()
    chunk_size=int(games/os.cpu_count())
    for i in range(games):
        #need this as a single iterable to use with multiprocessing.Pool
        true_boards.append((GenRandBoard(), ChooseNumber, PickRow))
    pr.enable()
    with Pool(os.cpu_count()) as p:
        results = p.map(PlayGame, true_boards, chunksize=chunk_size)
    pr.disable()
    reward = np.sum(results)

    print(reward / games)
    s = io.StringIO()
    sortby = SortKey.CUMULATIVE
    ps = pstats.Stats(pr, stream=s)
    ps.strip_dirs()
    ps.sort_stats(sortby)
    ps.print_stats('main')
    print(s.getvalue())

if __name__ == "__main__":
    freeze_support()
    main(256)
