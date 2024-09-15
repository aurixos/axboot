/*********************************************************************************/
/* Module Name:  file.h                                                          */
/* Project:      AurixOS                                                         */
/*                                                                               */
/* Copyright (c) 2024 Jozef Nagy                                                 */
/*                                                                               */
/* This source is subject to the MIT License.                                    */
/* See License.txt in the root of this repository.                               */
/* All other rights reserved.                                                    */
/*                                                                               */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    */
/* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      */
/* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   */
/* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        */
/* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, */
/* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE */
/* SOFTWARE.                                                                     */
/*********************************************************************************/

#ifndef _FIRMWARE_FILE_H
#define _FIRMWARE_FILE_H

#include <arch/firmware/file.h>
#include <stddef.h>

FILE *fw_file_open(FILE *directory, const char *path);
int fw_file_close(FILE *file);
int fw_file_read(FILE *file, uint64_t size, void *buffer);
int fw_file_write(FILE *file, uint64_t size, void *buffer);

int fw_file_size(FILE *file);

#endif /* _FIRMWARE_FILE_H */