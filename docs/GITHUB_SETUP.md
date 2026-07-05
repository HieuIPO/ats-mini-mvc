# Huong dan tao va quan ly GitHub cho ATS Mini

## 1. Tao repository tren GitHub

De nghi tao repo voi thong tin sau:

- Repository name: `ats-mini-mvc`
- Description: `He thong quan ly tuyen dung va theo doi ung vien - Do an Lap trinh Web MVC`
- Visibility: `Public`
- Add README: khong can neu da day source tu may len
- Add .gitignore: neu GitHub hoi thi chon `VisualStudio`

Neu repo da co san `README.md` tren may, co the tao repo trong GitHub khong can tick README.

## 2. Branch thong nhat

Dung cac branch sau:

| Branch | Muc dich |
|---|---|
| `main` | Ban on dinh de nop/demo |
| `develop` | Noi ghep code chung truoc khi dua len main |
| `auth-layout1` | Thanh vien 1: auth, phan quyen, layout, tich hop |
| `jobs2` | Thanh vien 2: quan ly tuyen dung |
| `applications3` | Thanh vien 3: ung tuyen, CV, trang thai, phong van |

## 3. Lenh day project len GitHub lan dau

Sau khi tao repo tren GitHub, chay cac lenh sau trong thu muc du an.

Thay `YOUR_USERNAME` bang ten GitHub cua ban:

```bash
git init
git add .
git commit -m "Initial ATS Mini project structure"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/ats-mini-mvc.git
git push -u origin main
```

## 4. Tao branch develop va branch cho tung thanh vien

```bash
git checkout -b develop
git push -u origin develop

git checkout -b auth-layout1
git push -u origin auth-layout1

git checkout develop
git checkout -b jobs2
git push -u origin jobs2

git checkout develop
git checkout -b applications3
git push -u origin applications3
```

Sau khi tao xong, quay lai `develop`:

```bash
git checkout develop
```

## 5. Cach moi thanh vien lam viec

Moi thanh vien clone repo ve may:

```bash
git clone https://github.com/YOUR_USERNAME/ats-mini-mvc.git
cd ats-mini-mvc
```

Thanh vien 1:

```bash
git checkout auth-layout1
```

Thanh vien 2:

```bash
git checkout jobs2
```

Thanh vien 3:

```bash
git checkout applications3
```

## 6. Cach cap nhat code hang ngay

Truoc khi code, nen lay code moi nhat:

```bash
git checkout develop
git pull origin develop
git checkout TEN_BRANCH_CUA_MINH
git merge develop
```

Vi du thanh vien 2:

```bash
git checkout develop
git pull origin develop
git checkout jobs2
git merge develop
```

## 7. Cach day code cua tung thanh vien

```bash
git add .
git commit -m "Mo ta ngan gon phan da lam"
git push origin TEN_BRANCH_CUA_MINH
```

Vi du:

```bash
git add .
git commit -m "Add job management CRUD"
git push origin jobs2
```

## 8. Pull Request

Khi lam xong mot phan:

1. Vao GitHub repo.
2. Chon tab Pull requests.
3. Tao Pull Request tu branch cua minh vao `develop`.
4. Nhom test lai.
5. Neu on thi merge vao `develop`.

Khong merge thang vao `main` khi chua chot ban demo.

## 9. Quy tac commit

Nen dat commit ngan gon, ro y:

```text
Add login and role authorization
Add shared admin layout
Add job CRUD screens
Add application upload CV
Add application status history
Fix database connection string example
Update final report screenshots
```

## 10. Khong nen dua len GitHub

Khong commit cac thu sau:

- Thu muc `.vs/`
- Thu muc `bin/`, `obj/`
- File `.mdf`, `.ldf`
- File CV that cua nguoi dung
- Mat khau that hoac thong tin rieng trong `Web.config`
- File build tam, file log

## 11. Ghi chu phan bien

Branch co so thu tu `auth-layout1`, `jobs2`, `applications3` giup nhan dien thanh vien nhanh, nhung nhom van nen ghi ro nguoi phu trach trong README hoac issue GitHub. Ten branch khong thay the cho viec quan ly task.

